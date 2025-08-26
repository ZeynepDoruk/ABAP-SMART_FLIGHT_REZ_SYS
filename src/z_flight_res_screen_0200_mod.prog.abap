*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_RES_SCREEN_0200_MOD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


MODULE status_0200 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE  sy-ucomm.
    WHEN '&BCK' .
      LEAVE TO SCREEN 0.
    WHEN '&EXIT'.  " Çıkış
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

MODULE display_flight_list OUTPUT.

  IF alv_grid IS INITIAL.

    "  ZPP_SCARR’dan desteklenen havayollarını çek
    SELECT carrid FROM zpp_scarr INTO TABLE lt_supported_airlines.

    "  Uygun havayollarını filtrele
    CLEAR lt_filtered.
    LOOP AT gt_flights INTO ls_flight.
      READ TABLE lt_supported_airlines WITH KEY table_line = ls_flight-airline TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        " İndirimli kişi başı fiyat hesapla

        DATA(lv_total_price) = ls_flight-price.
        DATA(lv_person_count) = gv_passenger_count.
        DATA(lv_price_per_person) = lv_total_price / lv_person_count.
        ls_flight-price = lv_price_per_person * '0.90'. " %10 indirim


        APPEND ls_flight TO lt_filtered.
      ENDIF.
    ENDLOOP.

    " Süreyi okunabilir formata çevir
    FIELD-SYMBOLS: <fs_flight> TYPE zstr_flight_data.
    LOOP AT lt_filtered ASSIGNING <fs_flight>.
      REPLACE ALL OCCURRENCES OF 'PT' IN <fs_flight>-duration WITH ''.
      REPLACE ALL OCCURRENCES OF 'H'  IN <fs_flight>-duration WITH 's '.
      REPLACE ALL OCCURRENCES OF 'M'  IN <fs_flight>-duration WITH 'dk'.
    ENDLOOP.

    "  ALV container ve grid oluştur
    CREATE OBJECT alv_container
      EXPORTING
        container_name = 'FLIGHT_CONTAINER'.

    CREATE OBJECT alv_grid
      EXPORTING
        i_parent = alv_container.

    CREATE OBJECT gr_handler.
    SET HANDLER gr_handler->handle_double_click FOR alv_grid.

    "  Field catalog
    CLEAR it_fieldcat.
    DEFINE add_fieldcat.
      CLEAR wa_fieldcat.
      wa_fieldcat-fieldname = &1.
      wa_fieldcat-scrtext_l = &2.
      wa_fieldcat-col_pos   = &3.
      APPEND wa_fieldcat TO it_fieldcat.
    END-OF-DEFINITION.

    add_fieldcat: 'FLIGHT_ID'     'Uçuş Kodu'        1,
                  'AIRLINE'       'Havayolu'         2,
                  'PRICE'         'Fiyat'            3,
                  'CURRENCY'      'Para Birimi'      4,
                  'DEP_AIRPORT'   'Kalkış Yeri'      5,
                  'ARR_AIRPORT'   'Varış Yeri'       6,
                  'DEP_TIME'      'Kalkış Zamanı'    7,
                  'ARR_TIME'      'Varış Zamanı'     8,
                  'DURATION'      'Uçuş Süresi'      9.

    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTR_FLIGHT_DATA'
        is_layout        = VALUE lvc_s_layo( sel_mode = 'A' )
      CHANGING
        it_outtab        = lt_filtered
        it_fieldcatalog  = it_fieldcat.

    "  ALV’de gösterilecek tabloyu global değişkene ata
    gt_flights = lt_filtered.

  ENDIF.

ENDMODULE.
