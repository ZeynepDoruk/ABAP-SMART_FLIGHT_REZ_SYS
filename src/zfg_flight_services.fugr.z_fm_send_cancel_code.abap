FUNCTION z_fm_send_cancel_code.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_EMAIL) TYPE  STRING
*"     REFERENCE(IV_TICKET_CODE) TYPE  STRING
*"     REFERENCE(IV_CODE) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EV_SUCCESS) TYPE  ABAP_BOOL
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------



  DATA: lo_client   TYPE REF TO if_http_client,
        lv_url      TYPE string,
        lv_request  TYPE string,
        lv_response TYPE string.

  "  Flask API endpoint
  lv_url = 'http://10.200.164.2:5002/send-cancel-code'.

  "  JSON body hazırla
  CONCATENATE
    '{ "email": "' iv_email '",'
    '"ticket_code": "' iv_ticket_code '",'
    '"code": "' iv_code '" }'
    INTO lv_request.

  "  HTTP client oluştur
  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_url
    IMPORTING
      client = lo_client
    EXCEPTIONS
      OTHERS = 1.

  IF sy-subrc <> 0 OR lo_client IS INITIAL.
    ev_success = abap_false.
    ev_message = 'HTTP istemcisi oluşturulamadı.'.
    RETURN.
  ENDIF.

  " Header ve POST içeriği
  lo_client->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
  lo_client->request->set_method( if_http_request=>co_request_method_post ).
  lo_client->request->set_cdata( lv_request ).

  " İsteği gönder
  CALL METHOD lo_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      OTHERS                     = 3.

  IF sy-subrc <> 0.
    ev_success = abap_false.
    ev_message = 'HTTP gönderim hatası.'.
    RETURN.
  ENDIF.

  "  Yanıt al
  CALL METHOD lo_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      OTHERS                     = 3.

  IF sy-subrc <> 0.
    ev_success = abap_false.
    ev_message = 'Sunucudan yanıt alınamadı.'.
    RETURN.
  ENDIF.

  "  Yanıt içeriğini al
  lv_response = lo_client->response->get_cdata( ).

  " JSON içinde success kontrolü
  IF lv_response CS '"success": true'.
    ev_success = abap_true.
    ev_message = 'İptal kodu e-posta ile gönderildi.'.
  ELSE.
    ev_success = abap_false.
    ev_message = |İptal kodu gönderilemedi. Yanıt: { lv_response }| .
  ENDIF.

  "  Bağlantıyı kapat
  CALL METHOD lo_client->close.

ENDFUNCTION.
