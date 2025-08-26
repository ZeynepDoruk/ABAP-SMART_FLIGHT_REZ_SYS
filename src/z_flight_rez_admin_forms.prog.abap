*&---------------------------------------------------------------------*
*& Include          Z_FLIGHT_REZ_ADMIN_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ADD_FLIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_flight.

  " Gerekli alanlar dolu mu?
  IF gv_carrid     IS INITIAL OR
     gv_connid     IS INITIAL OR
     gv_fldate     IS INITIAL OR
     gv_price      IS INITIAL OR
     gv_currency   IS INITIAL OR
     gv_cityfrom   IS INITIAL OR
     gv_cityto     IS INITIAL OR
     gv_deptime    IS INITIAL OR
     gv_arrtime    IS INITIAL OR
     gv_dep_airport IS INITIAL OR
     gv_arr_airport IS INITIAL OR
     gv_duration   IS INITIAL.

    MESSAGE 'Lütfen tüm alanları eksiksiz doldurun!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "  Aynı uçuş zaten var mı?
  SELECT SINGLE * INTO gs_flight
    FROM zpp_sflight
    WHERE carrid = gv_carrid
      AND connid = gv_connid
      AND fldate = gv_fldate.

  IF sy-subrc = 0.
    MESSAGE 'Bu uçuş zaten mevcut!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "  INSERT işlemi
  CLEAR gs_flight.
  gs_flight-carrid       = gv_carrid.
  gs_flight-connid       = gv_connid.
  gs_flight-fldate       = gv_fldate.
  gs_flight-price        = gv_price.
  gs_flight-currency     = gv_currency.
  gs_flight-cityfrom     = gv_cityfrom.
  gs_flight-cityto       = gv_cityto.
  gs_flight-deptime      = gv_deptime.
  gs_flight-arrtime      = gv_arrtime.
  gs_flight-dep_airport  = gv_dep_airport.
  gs_flight-arr_airport  = gv_arr_airport.
  gs_flight-duration     = gv_duration.

  INSERT zpp_sflight FROM gs_flight.

  IF sy-subrc = 0.
    MESSAGE 'Uçuş başarıyla eklendi.' TYPE 'S' DISPLAY LIKE 'E'.
    CLEAR: gv_carrid, gv_connid, gv_fldate, gv_price, gv_currency,
           gv_cityfrom, gv_cityto, gv_deptime, gv_arrtime,
           gv_dep_airport, gv_arr_airport, gv_duration.
  ELSE.
    MESSAGE 'Uçuş eklenemedi!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

FORM update_flight.

  " Gerekli alanlar kontrolü
  IF gv_carrid IS INITIAL OR
     gv_connid IS INITIAL OR
     gv_fldate IS INITIAL.

    MESSAGE 'Lütfen güncellenecek uçuşun CARRID, CONNID ve FLDATE bilgilerini girin!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "  Kayıt mevcut mu?
  SELECT SINGLE * INTO gs_flight
    FROM zpp_sflight
    WHERE carrid = gv_carrid
      AND connid = gv_connid
      AND fldate = gv_fldate.

  IF sy-subrc <> 0.
    MESSAGE 'Güncellenecek uçuş bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 3. Güncelleme işlemi
  gs_flight-price        = gv_price.
  gs_flight-currency     = gv_currency.
  gs_flight-cityfrom     = gv_cityfrom.
  gs_flight-cityto       = gv_cityto.
  gs_flight-deptime      = gv_deptime.
  gs_flight-arrtime      = gv_arrtime.
  gs_flight-dep_airport  = gv_dep_airport.
  gs_flight-arr_airport  = gv_arr_airport.
  gs_flight-duration     = gv_duration.

  UPDATE zpp_sflight FROM gs_flight.

  IF sy-subrc = 0.
    MESSAGE 'Uçuş bilgisi başarıyla güncellendi.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE 'Güncelleme sırasında hata oluştu.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DELETE_FLIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_flight.

  "  Zorunlu alanlar kontrolü
  IF gv_carrid IS INITIAL OR gv_connid IS INITIAL OR gv_fldate IS INITIAL.
    MESSAGE 'Lütfen silinecek uçuşun CARRID, CONNID ve FLDATE bilgilerini girin!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "  Kayıt mevcut mu?
  SELECT SINGLE * INTO gs_flight FROM zpp_sflight
    WHERE carrid = gv_carrid
      AND connid = gv_connid
      AND fldate = gv_fldate.

  IF sy-subrc <> 0.
    MESSAGE 'Silinecek uçuş bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Pop-up olmadan doğrudan sil
  DELETE FROM zpp_sflight
    WHERE carrid = gv_carrid
      AND connid = gv_connid
      AND fldate = gv_fldate.

  IF sy-subrc = 0.
    MESSAGE 'Uçuş başarıyla silindi.' TYPE 'S'.
    CLEAR: gv_carrid, gv_connid, gv_fldate, gv_price, gv_currency.
  ELSE.
    MESSAGE 'Silme işlemi sırasında hata oluştu.' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form LIST_FLIGHTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM list_flights.

  DATA: lt_fcat     TYPE lvc_t_fcat,
        lt_flights  TYPE TABLE OF zpp_sflight,
        ls_where    TYPE zpp_sflight.

  " Filtreleri ls_where yapısına aktar
  IF gv_carrid IS NOT INITIAL.
    ls_where-carrid = gv_carrid.
  ENDIF.
  IF gv_connid IS NOT INITIAL.
    ls_where-connid = gv_connid.
  ENDIF.
  IF gv_fldate IS NOT INITIAL.
    ls_where-fldate = gv_fldate.
  ENDIF.
  IF gv_cityfrom IS NOT INITIAL.
    ls_where-cityfrom = gv_cityfrom.
  ENDIF.
  IF gv_cityto IS NOT INITIAL.
    ls_where-cityto = gv_cityto.
  ENDIF.
  IF gv_dep_airport IS NOT INITIAL.
    ls_where-dep_airport = gv_dep_airport.
  ENDIF.
  IF gv_arr_airport IS NOT INITIAL.
    ls_where-arr_airport = gv_arr_airport.
  ENDIF.
  IF gv_price IS NOT INITIAL.
    ls_where-price = gv_price.
  ENDIF.
  IF gv_currency IS NOT INITIAL.
    ls_where-currency = gv_currency.
  ENDIF.
  IF gv_deptime IS NOT INITIAL.
    ls_where-deptime = gv_deptime.
  ENDIF.
  IF gv_arrtime IS NOT INITIAL.
    ls_where-arrtime = gv_arrtime.
  ENDIF.
  IF gv_duration IS NOT INITIAL.
    ls_where-duration = gv_duration.
  ENDIF.

  "  Eğer en az bir filtre girildiyse
  IF gv_carrid IS NOT INITIAL OR
     gv_connid IS NOT INITIAL OR
     gv_fldate IS NOT INITIAL OR
     gv_cityfrom IS NOT INITIAL OR
     gv_cityto IS NOT INITIAL OR
     gv_dep_airport IS NOT INITIAL OR
     gv_arr_airport IS NOT INITIAL OR
     gv_price IS NOT INITIAL OR
     gv_currency IS NOT INITIAL OR
     gv_deptime IS NOT INITIAL OR
     gv_arrtime IS NOT INITIAL OR
     gv_duration IS NOT INITIAL.

    SELECT *
      FROM zpp_sflight
      WHERE ( carrid      = @ls_where-carrid      OR @ls_where-carrid      = '' )
        AND ( connid      = @ls_where-connid      OR @ls_where-connid      = 0 )
        AND ( fldate      = @ls_where-fldate      OR @ls_where-fldate      = '00000000' )
        AND ( cityfrom    = @ls_where-cityfrom    OR @ls_where-cityfrom    = '' )
        AND ( cityto      = @ls_where-cityto      OR @ls_where-cityto      = '' )
        AND ( dep_airport = @ls_where-dep_airport OR @ls_where-dep_airport = '' )
        AND ( arr_airport = @ls_where-arr_airport OR @ls_where-arr_airport = '' )
        AND ( price       = @ls_where-price       OR @ls_where-price       = 0 )
        AND ( currency    = @ls_where-currency    OR @ls_where-currency    = '' )
        AND ( deptime     = @ls_where-deptime     OR @ls_where-deptime     = '' )
        AND ( arrtime     = @ls_where-arrtime     OR @ls_where-arrtime     = '' )
        AND ( duration    = @ls_where-duration    OR @ls_where-duration    = '' )
      INTO TABLE @lt_flights.

  ELSE.
    SELECT * INTO TABLE lt_flights FROM zpp_sflight.
  ENDIF.

  " Veri yoksa
  IF lt_flights IS INITIAL.
    MESSAGE 'Eşleşen uçuş bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "  ALV oluştur (ilk kez ise)
  IF gr_alv_container_flight IS INITIAL.
    CREATE OBJECT gr_alv_container_flight
      EXPORTING
        container_name = 'SUB5'.  " Container adı layout'taki ile aynı olmalı

    CREATE OBJECT gr_alv_grid_flight
      EXPORTING
        i_parent = gr_alv_container_flight.
  ENDIF.

  " ALV’yi göster
  CALL METHOD gr_alv_grid_flight->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZPP_SFLIGHT'
    CHANGING
      it_outtab        = lt_flights
      it_fieldcatalog  = lt_fcat.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form FILL_CUSTOMER_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_customer_alv.

  DATA: lt_fcat TYPE lvc_t_fcat.

  DATA: lt_filtered TYPE TABLE OF zpp_scustom,
        ls_where    TYPE zpp_scustom.

*  Filtre alanlarını WHERE yapısına aktar
  IF gv_flt_name IS NOT INITIAL.
    ls_where-name = gv_flt_name.
  ENDIF.

  IF gv_flt_surname IS NOT INITIAL.
    ls_where-surname = gv_flt_surname.
  ENDIF.

  IF gv_flt_city IS NOT INITIAL.
    ls_where-city = gv_flt_city.
  ENDIF.

  IF gv_flt_email IS NOT INITIAL.
    ls_where-email = gv_flt_email.
  ENDIF.

  IF gv_flt_form IS NOT INITIAL.
    ls_where-form = gv_flt_form.
  ENDIF.

*  En az bir filtre girilmişse
  IF gv_flt_name     IS NOT INITIAL OR
     gv_flt_surname  IS NOT INITIAL OR
     gv_flt_city     IS NOT INITIAL OR
     gv_flt_email    IS NOT INITIAL OR
     gv_flt_form     IS NOT INITIAL.

    SELECT * FROM zpp_scustom
      WHERE ( name    = @ls_where-name    OR @ls_where-name    = '' )
        AND ( surname = @ls_where-surname OR @ls_where-surname = '' )
        AND ( city    = @ls_where-city    OR @ls_where-city    = '' )
        AND ( email   = @ls_where-email   OR @ls_where-email   = '' )
        AND ( form    = @ls_where-form    OR @ls_where-form    = '' )
      INTO TABLE @lt_filtered.

  ELSE.
    SELECT * INTO TABLE lt_filtered FROM zpp_scustom.
  ENDIF.

*  Hiç müşteri yoksa
  IF lt_filtered IS INITIAL.
    MESSAGE 'Eşleşen müşteri kaydı bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* ALV container ve grid nesnesini oluştur
  IF gr_alv_container IS INITIAL.
    CREATE OBJECT gr_alv_container
      EXPORTING
        container_name = 'SUB6'.

    CREATE OBJECT gr_alv_grid
      EXPORTING
        i_parent = gr_alv_container.
  ENDIF.

*  ALV’yi göster
  CALL METHOD gr_alv_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZPP_SCUSTOM'
    CHANGING
      it_outtab        = lt_filtered
      it_fieldcatalog  = lt_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_BOOKING_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_booking_alv.

  DATA: lt_fcat  TYPE lvc_t_fcat,
        wa_fcat  TYPE lvc_s_fcat,
        ls_where TYPE zpp_sbook.

*  Filtre parametrelerini WHERE yapısına aktar
  IF gv_flt_ticketcode IS NOT INITIAL.
    ls_where-ticketcode = gv_flt_ticketcode.
  ENDIF.
  IF gv_flt_carrid IS NOT INITIAL.
    ls_where-carrid = gv_flt_carrid.
  ENDIF.
  IF gv_flt_connid IS NOT INITIAL.
    ls_where-connid = gv_flt_connid.
  ENDIF.
  IF gv_flt_fldate IS NOT INITIAL.
    ls_where-fldate = gv_flt_fldate.
  ENDIF.

*  Rezervasyon verilerini çek
  IF gv_flt_ticketcode IS NOT INITIAL OR
     gv_flt_carrid     IS NOT INITIAL OR
     gv_flt_connid     IS NOT INITIAL OR
     gv_flt_fldate     IS NOT INITIAL.

    SELECT * FROM zpp_sbook
      WHERE ( ticketcode = @ls_where-ticketcode OR @ls_where-ticketcode = '' )
        AND ( carrid     = @ls_where-carrid     OR @ls_where-carrid     = '' )
        AND ( connid     = @ls_where-connid     OR @ls_where-connid     = '' )
        AND ( fldate     = @ls_where-fldate     OR @ls_where-fldate     = '00000000' )
      INTO TABLE @gt_bookings.
  ELSE.
    SELECT * INTO TABLE gt_bookings FROM zpp_sbook.
  ENDIF.

  IF gt_bookings IS INITIAL.
    MESSAGE 'Eşleşen rezervasyon bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  Field catalog manuel tanımlanıyor – PRICE ve LOCCURKEY eklendi
  DEFINE add_fieldcat.
    CLEAR wa_fcat.
    wa_fcat-fieldname = &1.
    wa_fcat-scrtext_l = &2.
    wa_fcat-col_pos   = &3.
    APPEND wa_fcat TO lt_fcat.
  END-OF-DEFINITION.

  add_fieldcat:
    'TICKETCODE'  'Bilet Kodu'         1,
    'FLDATE'      'Uçuş Tarihi'        2,
    'BOOKID'      'Rezervasyon No.'    3,
    'CUSTOMID'    'Müşteri No.'        4,
    'CARRID'      'Havayolu'           5,
    'CONNID'      'Uçuş No.'           6,
    'PRICE'       'Fiyat'              7,
    'LOCCURKEY'   'Para Brm.'          8,
    'ORDER_DATE'  'Rezervasyon Tarihi' 9,
    'PASSNAME'    'Yolcu Adı'         10,
    'PASSFORM'    'Hitap'             11,
    'PASSBIRTH'   'Doğum Tarihi'      12.

* ALV nesnelerini sıfırla ve yeniden oluştur
  FREE: gr_book_container, gr_book_grid.

  CREATE OBJECT gr_book_container
    EXPORTING
      container_name = 'SUB7'.

  CREATE OBJECT gr_book_grid
    EXPORTING
      i_parent = gr_book_container.

* ALV’yi çiz – i_structure_name kullanılmadan
  CALL METHOD gr_book_grid->set_table_for_first_display
    CHANGING
      it_outtab       = gt_bookings
      it_fieldcatalog = lt_fcat.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form DELETE_SELECTED_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_selected_request.

  DATA: lv_index       TYPE sy-tabix,
        lv_ticket      TYPE zpp_sbook-ticketcode,
        lv_customid    TYPE zpp_scustom-id,
        lv_answer      TYPE c,
        lv_booking_cnt TYPE i.

  " ALV'de satır seçildi mi?
  CALL METHOD gr_alv_grid_del->get_current_cell
    IMPORTING
      e_row = lv_index.

  IF lv_index IS INITIAL.
    MESSAGE 'Lütfen silmek istediğiniz talebi seçin.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Satır bilgilerini oku
  READ TABLE gt_delete_log INTO gs_delete_log INDEX lv_index.
  IF sy-subrc <> 0.
    MESSAGE 'Seçilen log satırı okunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  lv_ticket   = gs_delete_log-ticketcode.
  lv_customid = gs_delete_log-customid.

  " Onay al
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Silme Onayı'
      text_question         = |{ lv_ticket } nolu rezervasyon silinsin mi?|
      text_button_1         = 'Evet'
      text_button_2         = 'Hayır'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.

  " SBOOK kaydını sil
  DELETE FROM zpp_sbook
    WHERE ticketcode = lv_ticket
      AND customid   = lv_customid.

  " Aynı müşteri başka rezervasyona sahip mi?
  SELECT COUNT(*) INTO lv_booking_cnt
    FROM zpp_sbook
    WHERE customid = lv_customid.

  " Eğer başka rezervasyonu yoksa SCUSTOM'u da sil
  IF lv_booking_cnt = 0.
    DELETE FROM zpp_scustom WHERE id = lv_customid.
  ENDIF.

  " LOG kaydı sil
  DELETE FROM zpp_delete_req_l
    WHERE ticketcode = lv_ticket
      AND customid   = lv_customid.

  " ALV'den sil ve mesaj göster
  IF sy-subrc = 0.
    MESSAGE 'Rezervasyon silindi. Müşteri bilgisi kontrol edildi.' TYPE 'S'.
    DELETE gt_delete_log INDEX lv_index.
    CALL METHOD gr_alv_grid_del->refresh_table_display.
  ELSE.
    MESSAGE 'Silme işlemi başarısız oldu!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form LIST_DELETE_REQUESTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM list_delete_requests.

  "Silme log verilerini al
  SELECT * INTO TABLE gt_delete_log FROM zpp_delete_req_l.

  "Veri yoksa uyarı ver
  IF gt_delete_log IS INITIAL.
    MESSAGE 'Silme talebi bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " ALV bileşenlerini oluştur
  CREATE OBJECT gr_container_del
    EXPORTING
      container_name = 'SUB8'. " Custom Control adın neyse onu yaz

  CREATE OBJECT gr_alv_grid_del
    EXPORTING
      i_parent = gr_container_del.

  CALL METHOD gr_alv_grid_del->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZPP_DELETE_REQ_L'
    CHANGING
      it_outtab        = gt_delete_log.

  " Görünürlük kontrolü set et
  gv_show_alv_del = abap_true.

ENDFORM.

FORM fill_form_dropdown.

  DATA: lt_form_vals TYPE vrm_values,
        ls_form_val  TYPE vrm_value.

  CLEAR lt_form_vals.

  ls_form_val-key  = 'bay'.
  ls_form_val-text = 'bay'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'bayan'.
  ls_form_val-text = 'bayan'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'NON'.
  ls_form_val-text = 'belirtmiyorum'.
  APPEND ls_form_val TO lt_form_vals.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_FORM'
      values = lt_form_vals.

ENDFORM.
