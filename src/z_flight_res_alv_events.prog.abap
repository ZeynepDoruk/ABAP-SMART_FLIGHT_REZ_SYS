CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_double_click.

    " ALV’deki satırı oku
    READ TABLE lt_filtered INTO gs_selected_flight INDEX e_row-index.
    IF sy-subrc <> 0.
      MESSAGE 'Satır bulunamadı.' TYPE 'E'.
      RETURN.
    ENDIF.

    "  Model API fonksiyonunu çağır
    CALL FUNCTION 'Z_FM_GET_DELAY_PREDICTION'
      EXPORTING
        iv_flight          = gs_selected_flight
        iv_passenger_count = gv_passenger_count
      IMPORTING
        ev_probability     = gv_probability
        ev_error           = gv_delay_error.

    " Hata yoksa popup hazırla
    IF gv_delay_error IS INITIAL.
      PERFORM show_delay_popup USING gs_selected_flight gv_probability.
    ELSE.
      MESSAGE gv_delay_error TYPE 'E'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
