class ZCL_MIMESYNC_SERVICE definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MIMESYNC_SERVICE IMPLEMENTATION.


  METHOD if_http_extension~handle_request.

    DATA: lv_mime_url          TYPE string,
          lv_mime_content_str  TYPE string,
          lv_mime_content_xstr TYPE xstring,
          lv_request_number    TYPE trkorr,
          lo_mr_api            TYPE REF TO if_mr_api.


    lv_mime_url = server->request->get_form_field( name = 'mime_url' ).
    lv_mime_content_str = server->request->get_form_field( name = 'mime_content' ).
    lv_request_number = server->request->get_form_field( name = 'request_number' ).







    IF lv_mime_url is INITIAL .
      server->response->set_status( code = '400' reason = 'parameter missing' ).
      server->response->set_cdata( data =  'mime_url is missing.' ).
      exit.
    ENDIF.
    IF lv_mime_content_str is INITIAL.
      server->response->set_status( code = '400' reason = 'parameter missing' ).
      server->response->set_cdata( data =  'mime_content is missing.' ).
      exit.
    ENDIF.
    IF lv_request_number  is INITIAL .
      server->response->set_status( code = '400' reason = 'parameter missing' ).
      server->response->set_cdata( data =  'request_number is missing.' ).
      exit.
    ENDIF.


    CALL METHOD cl_http_utility=>if_http_utility~decode_x_base64
      EXPORTING
        encoded = lv_mime_content_str
      RECEIVING
        decoded = lv_mime_content_xstr.


    lo_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ).

    lo_mr_api->put(
              EXPORTING
                i_url                         = lv_mime_url
                i_content                     = lv_mime_content_xstr
                i_corr_number                 = lv_request_number
                i_suppress_dialogs            = 'X'

              EXCEPTIONS
                parameter_missing             = 1
                error_occured                 = 2
                cancelled                     = 3
                permission_failure            = 4
                data_inconsistency            = 5
                new_loio_already_exists       = 6
                is_folder                     = 7
                OTHERS                        = 8 ).

    DATA: l_sysubrc_str TYPE string.
    l_sysubrc_str = sy-subrc.
    IF sy-subrc <> 0.
      server->response->set_status( code = '500' reason = 'mime_repository_api exception' ).
      server->response->set_cdata( data =  l_sysubrc_str ).
      EXIT.
    ENDIF.

    server->response->set_status( code = '200' reason = 'OK' ).
    server->response->set_cdata( data =  l_sysubrc_str ).


  ENDMETHOD.
ENDCLASS.
