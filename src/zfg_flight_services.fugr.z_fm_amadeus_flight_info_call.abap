FUNCTION z_fm_amadeus_flight_info_call.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ORIGIN) TYPE  ZPP_SPFLI-CITYFROM
*"     REFERENCE(IV_DEST) TYPE  ZPP_SPFLI-CITYTO
*"     REFERENCE(IV_DATE) TYPE  ZPP_SFLIGHT-FLDATE
*"     REFERENCE(IV_ADULTS) TYPE  INT4
*"  EXPORTING
*"     REFERENCE(EV_ERROR) TYPE  STRING
*"     REFERENCE(EV_TT_FLIGHTS) TYPE  ZTT_FLIGHT_DATA
*"----------------------------------------------------------------------

  DATA: lo_http_client TYPE REF TO if_http_client,
        lv_url         TYPE string,
        lv_request     TYPE string,
        lv_response    TYPE string,
        lv_date_str    TYPE string.

  "  Tarihi formatla → 'YYYY-MM-DD'
  lv_date_str = |{ iv_date+0(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }|.

  "  JSON verisini oluştur (adults artık tırnaksız sayı olarak gidiyor!)
 DATA: lv_adults_str TYPE char10.
WRITE iv_adults TO lv_adults_str.
CONDENSE lv_adults_str. " Boşlukları sil

CONCATENATE
  '{ "origin": "' iv_origin '",'
  '"destination": "' iv_dest '",'
  '"date": "' lv_date_str '",'
  '"adults": ' lv_adults_str ' }'
  INTO lv_request.


  "  Flask API URL
  lv_url = 'http://10.200.164.2:5050/flightsearch'.



  " HTTP client oluştur
  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_url
    IMPORTING
      client = lo_http_client
    EXCEPTIONS
      OTHERS = 1.

  IF sy-subrc <> 0.
    ev_error = 'HTTP bağlantısı kurulamadı'.
    RETURN.
  ENDIF.

  " Header ve veri gönder
  lo_http_client->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
  lo_http_client->request->set_cdata( lv_request ).

  " İsteği gönder
  CALL METHOD lo_http_client->send.
  CALL METHOD lo_http_client->receive.

  "  Yanıtı al
  lv_response = lo_http_client->response->get_cdata( ).

  " JSON yanıtını parse et
  TRY.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json = lv_response
        CHANGING
          data = ev_tt_flights
      ).
    CATCH cx_root INTO DATA(lx_error).
      ev_error = lx_error->get_text( ).
      RETURN.
  ENDTRY.
  WRITE: / 'Gönderilen JSON:', lv_request.


ENDFUNCTION.
