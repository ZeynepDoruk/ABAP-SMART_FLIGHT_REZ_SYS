*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_RES_SCREEN_0110_MOD.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.

  SET PF-STATUS '0200'.

  " Kalan deneme hakkını hesapla (ekranda gösterilecek)
  gv_remaining_attempt = 3 - gv_attempt_count.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0110 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  CASE sy-ucomm.

    WHEN '&BCK'.  " Geri dön
      SET SCREEN 0.

    WHEN '&CONF'.  " Doğrulama
      PERFORM  confirm_user_code.

    WHEN '&EXIT'.  " Çıkış
      SET SCREEN 0.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form   confirm_user_code.
FORM  confirm_user_code.


  ADD 1 TO gv_attempt_count.
  CONDENSE gv_user_code.
  CONDENSE gv_sent_code.

  IF gv_user_code = gv_sent_code.

    IF gv_is_update = abap_true.

      " Güncelleme için müşteri bilgilerini al (ZPP_SCUSTOM)
      SELECT SINGLE * INTO gs_customer
        FROM zpp_scustom
        WHERE email = gv_cancel_email.

      IF sy-subrc <> 0.
        MESSAGE 'Müşteri bilgisi bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

*      " Global alanlara yeni update değişkenlerini aktar
*      gv_updte_name      = gs_customer-name.
*      gv_updte_surname   = gs_customer-surname.
*      gv_updte_city      = gs_customer-city.
*      gv_updte_phone     = gs_customer-telephone.
*      gv_updte_form      = gs_customer-form.
*      gv_updte_birthdate = gs_customer-passbirth. " Eğer doğum tarihi tutuluyorsa

      CALL SCREEN 0120.
      RETURN.

    ELSE.

      " ICKETCODE üzerinden rezervasyon detaylarını al (ZPP_SBOOK)
      DATA: lv_bookid   TYPE zpp_sbook-bookid,
            lv_fldate   TYPE zpp_sbook-fldate,
            lv_connid   TYPE zpp_sbook-connid,
            lv_carrid   TYPE zpp_sbook-carrid,
            lv_customid TYPE zpp_sbook-customid.

      SELECT SINGLE bookid
                    fldate
                    connid
                    carrid
                    customid
        INTO (lv_bookid, lv_fldate, lv_connid, lv_carrid, lv_customid)
        FROM zpp_sbook
        WHERE ticketcode = gv_cancel_ticket_code.

      IF sy-subrc <> 0.
        MESSAGE 'Bu ticket koduna ait bir rezervasyon bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      " LOG tablosuna silme isteği kaydet (ZPP_DELETE_REQ_L)
      DATA: ls_log TYPE zpp_delete_req_l.

      ls_log-mandt       = sy-mandt.
      ls_log-ticketcode  = gv_cancel_ticket_code.
      ls_log-customid    = lv_customid.
      ls_log-bookid      = lv_bookid.
      ls_log-fldate      = lv_fldate.
      ls_log-connid      = lv_connid.
      ls_log-carrid      = lv_carrid.
      ls_log-req_date    = sy-datum.
      ls_log-req_time    = sy-uzeit.
      ls_log-is_approved = ''.

      INSERT zpp_delete_req_l FROM ls_log.

      IF sy-subrc = 0.
        MESSAGE 'Silme isteği log tablosuna eklendi. Admin onayı bekleniyor.' TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE 'Log kaydı eklenemedi!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

      LEAVE TO SCREEN 0100.
      RETURN.

    ENDIF.

  ELSE.
    IF gv_attempt_count >= 3.
      MESSAGE '3 kez hatalı kod girdiniz. İşlem iptal edildi.' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0100.
    ELSE.
      MESSAGE |Kod hatalı! Kalan hakkınız: { 3 - gv_attempt_count }| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.
