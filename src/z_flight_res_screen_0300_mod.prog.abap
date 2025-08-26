*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_RES_SCREEN_0300_MOD
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  "  Menü statüsü belirle (Eğer 0300 için özel PF-STATUS varsa düzelt!)
  SET PF-STATUS '0200'.

  "  Ünvan dropdown'unu doldur
  PERFORM fill_form_dropdown.

  " Dinamik yolcu bilgisi yazısı oluştur (örneğin: 2. Yolcunun Bilgileri)
  gv_passenger_text = |{ gv_current_person }. Yolcunun Bilgileri|.

  "  Butonların görünürlüğünü kişi sayısına göre ayarla
  LOOP AT SCREEN.

    " KAYDET butonu
    IF screen-name = 'BUT_SAVE'.
      IF gv_passenger_count = 1 OR gv_current_person = gv_passenger_count.
        screen-invisible = 0.
        screen-active    = 1.
      ELSE.
        screen-invisible = 1.
        screen-active    = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    " DEVAM butonu
    IF screen-name = 'BUT_CONT'.
      IF gv_passenger_count > 1 AND gv_current_person < gv_passenger_count.
        screen-invisible = 0.
        screen-active    = 1.
      ELSE.
        screen-invisible = 1.
        screen-active    = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0300 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE sy-ucomm.

    WHEN '&CONT'.  " DEVAM butonu
      PERFORM append_customer_to_table.
      ADD 1 TO gv_current_person.
      CLEAR: gv_name, gv_surname, gv_form, gv_city, gv_phone, gv_email, gv_birthdate.
      LEAVE TO SCREEN '0300'.

    WHEN '&SAVE'.  " KAYDET butonu
      PERFORM append_customer_to_table.
      IF gt_customers IS INITIAL.
        MESSAGE 'Lütfen geçerli yolcu bilgisi giriniz!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      PERFORM save_booking.  " Tüm yolcuları tek seferde kaydeder

      MESSAGE 'Tüm rezervasyonlar başarıyla kaydedildi.' TYPE 'S'.
      CLEAR: gt_customers[], gv_current_person.
      LEAVE TO SCREEN 0100.

    WHEN '&BCK'.
      PERFORM handle_back_action.

    WHEN '&EXT'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
