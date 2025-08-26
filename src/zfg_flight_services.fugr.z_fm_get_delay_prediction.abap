

FUNCTION z_fm_get_delay_prediction.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_FLIGHT) TYPE  ZSTR_FLIGHT_DATA
*"     REFERENCE(IV_PASSENGER_COUNT) TYPE  INT4
*"  EXPORTING
*"     REFERENCE(EV_PROBABILITY) TYPE  F
*"     REFERENCE(EV_ERROR) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: lo_http_client TYPE REF TO if_http_client,
        lv_url         TYPE string,
        lv_body        TYPE string,
        lv_response    TYPE string,
        lv_distance    TYPE f.

  " tarih parçalama
  DATA: lv_month             TYPE n LENGTH 2,
        lv_day               TYPE n LENGTH 2,
        lv_hour              TYPE i,
        lv_min               TYPE i,
        lv_sched_dep_minutes TYPE i.

  lv_month = iv_flight-dep_time+5(2).
  lv_day   = iv_flight-dep_time+8(2).
  lv_hour  = iv_flight-dep_time+11(2).
  lv_min   = iv_flight-dep_time+14(2).
  lv_sched_dep_minutes = lv_hour * 60 + lv_min.

  " Mesafe hesapla
  PERFORM cal_dis_from_duration USING iv_flight-duration CHANGING lv_distance.

  " JSON input tanımı
  TYPES: BEGIN OF ty_model_input,
           month                        TYPE i,
           day                          TYPE i,
           dep_time_hour                TYPE i,
           origin                       TYPE string,
           dest                         TYPE string,
           distance                     TYPE f,
           name                         TYPE char30,
           sched_dep_time_total_minutes TYPE i,
         END OF ty_model_input.

  DATA: ls_model_input TYPE ty_model_input.
  "  Havayolu tam adını ZPP_SCARR’dan al
  DATA lv_airline_name type char30.
  SELECT SINGLE carrname INTO lv_airline_name
    FROM zpp_scarr
    WHERE carrid = iv_flight-airline.

  IF sy-subrc <> 0.
    ev_error = |Havayolu kodu bulunamadı: { iv_flight-airline }|.
    RETURN.
  ENDIF.

  ls_model_input-name = lv_airline_name.

  " JSON input verileri
  ls_model_input-month                         = lv_month.
  ls_model_input-day                           = lv_day.
  ls_model_input-dep_time_hour                 = lv_hour.
  ls_model_input-origin                        = iv_flight-dep_airport.
  ls_model_input-dest                          = iv_flight-arr_airport.
  ls_model_input-distance                      = lv_distance.
  ls_model_input-name                          = lv_airline_name.
  ls_model_input-sched_dep_time_total_minutes  = lv_sched_dep_minutes.

  " JSON oluştur

  WRITE: / 'SAP Uçuş Havayolu İsmi:', lv_airline_name.
  CALL METHOD /ui2/cl_json=>serialize
    EXPORTING
      data        = ls_model_input
      pretty_name = /ui2/cl_json=>pretty_mode-low_case
    RECEIVING
      r_json      = lv_body.

  WRITE: / 'JSON BODY:', lv_body.

  "  API
  lv_url = 'http://10.200.164.2:5001/predict_delay'.

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

  lo_http_client->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
  lo_http_client->request->set_cdata( lv_body ).

  CALL METHOD lo_http_client->send.
  CALL METHOD lo_http_client->receive.

  lv_response = lo_http_client->response->get_cdata( ).

  "  Yanıttan gecikme olasılığı string olarak ayrıştır
  DATA: lv_json_cut TYPE string,
        lv_value    TYPE string.

  FIND '"probability":' IN lv_response MATCH OFFSET DATA(lv_index).
  IF sy-subrc = 0.
    lv_json_cut = lv_response+lv_index.
    SPLIT lv_json_cut AT ':' INTO DATA(dummy1) lv_value.
    SPLIT lv_value AT '}' INTO lv_value dummy1.
    ev_probability = lv_value.
  ELSE.
    ev_error = '⚠ Yanıt içinde "probability" alanı bulunamadı.'.
  ENDIF.


ENDFUNCTION.
INCLUDE z_flight_reservation_top.
INCLUDE z_flight_reservation_forms.
INCLUDE z_flight_res_alv_events.
