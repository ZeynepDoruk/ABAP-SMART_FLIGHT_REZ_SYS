*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_RESERVATION_FORMS.
*----------------------------------------------------------------------*




*&---------------------------------------------------------------------*
*& Form FILL_CITYFROM_DROPDOWN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_cityfrom_dropdown .

  CLEAR: gt_cityfrom_vals, lt_cityfrom, ls_cityfrom.

  " Kabul edilen kalkış kodları
  SELECT DISTINCT cityfrom, airpfrom
    INTO TABLE @lt_cityfrom
    FROM zpp_spfli
    WHERE airpfrom IN ('EWR', 'JFK', 'LGA').

  LOOP AT lt_cityfrom INTO ls_cityfrom.

    " Aynı şehir birden fazla satırda olabilir, tekrar ekleme
    READ TABLE gt_cityfrom_vals WITH KEY key = ls_cityfrom-airpfrom TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      gs_city_value-key  = ls_cityfrom-airpfrom.  " API’ye gidecek kod
      gs_city_value-text = |{ ls_cityfrom-cityfrom } ({ ls_cityfrom-airpfrom })|.   " Kullanıcının gördüğü şehir
      APPEND gs_city_value TO gt_cityfrom_vals.
    ENDIF.

  ENDLOOP.

  gv_id_cityfrom = 'GV_CITYFROM'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_id_cityfrom
      values = gt_cityfrom_vals.

ENDFORM.

FORM fill_cityto_dropdown .

  CLEAR: gt_cityto_vals, lt_cityto, ls_cityto.

  " Kabul edilen varış kodları
  SELECT DISTINCT cityto, airpto
    INTO TABLE @lt_cityto
    FROM zpp_spfli
    WHERE airpto IN ('SFO', 'MIA', 'ORD').

  LOOP AT lt_cityto INTO ls_cityto.

    READ TABLE gt_cityto_vals WITH KEY key = ls_cityto-airpto TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      gs_city_value-key  = ls_cityto-airpto.  " API’ye gönderilecek
      gs_city_value-text = ls_cityto-cityto.  " Kullanıcının gördüğü
      APPEND gs_city_value TO gt_cityto_vals.
    ENDIF.

  ENDLOOP.

  gv_id_cityto = 'GV_CITYTO'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_id_cityto
      values = gt_cityto_vals.

ENDFORM.









*&---------------------------------------------------------------------*
*& Form SEARCH_FLIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_flight .

  "  Zorunlu alan kontrolleri
  IF gv_cityfrom IS INITIAL OR gv_cityto IS INITIAL OR
     gv_flight_date IS INITIAL OR gv_passenger_count IS INITIAL.
    MESSAGE 'Lütfen tüm alanları doldurun!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_flight_date < sy-datum.
    MESSAGE 'Geçmiş bir tarih seçilemez!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "  API çağrısı yapan function module
  CALL FUNCTION 'Z_FM_AMADEUS_FLIGHT_INFO_CALL'
    EXPORTING
      iv_origin     = gv_cityfrom
      iv_dest       = gv_cityto
      iv_date       = gv_flight_date
      iv_adults     = gv_passenger_count
    IMPORTING
      ev_error      = gv_error_message
      ev_tt_flights = gt_flights.

  " Hata mesajı varsa çık
  IF gv_error_message IS NOT INITIAL.
    MESSAGE gv_error_message TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "  Gelen uçuşlar kontrol – log
  WRITE: / 'Gelen uçuş sayısı:', lines( gt_flights ).

  CALL SCREEN '0200'.

ENDFORM.



FORM cal_dis_from_duration
  USING    iv_duration TYPE zde_duration
  CHANGING ev_distance TYPE f.

  DATA: lv_hour_txt     TYPE string VALUE '0',
        lv_min_txt      TYPE string VALUE '0',
        lv_hour         TYPE i,
        lv_min          TYPE i,
        lv_all_minutes  TYPE i,
        lv_int_distance TYPE i.

  " Süreyi ayrıştır: PT6H15M gibi (saat + dakika)
  FIND REGEX 'PT(\d{1,2})H(\d{1,2})M' IN iv_duration
       SUBMATCHES lv_hour_txt lv_min_txt.

  IF sy-subrc <> 0.
    " Sadece dakika varsa → PT45M
    FIND REGEX 'PT(\d{1,2})M' IN iv_duration
         SUBMATCHES lv_min_txt.
  ENDIF.

  IF sy-subrc <> 0.
    " Sadece saat varsa → PT2H
    FIND REGEX 'PT(\d{1,2})H' IN iv_duration
         SUBMATCHES lv_hour_txt.
  ENDIF.

  " Karakter verileri sayıya çevir
  lv_hour = lv_hour_txt.
  lv_min  = lv_min_txt.

  " Toplam dakika
  lv_all_minutes = lv_hour * 60 + lv_min.

  " Ortalama ticari uçuş hızı ≈ 635 km/saat
  ev_distance = lv_all_minutes * 635 / 60.

  "  Float değeri tam sayıya çevir (bilimsel gösterim ve ondalık engellenir)
  lv_int_distance = ev_distance.
  ev_distance = lv_int_distance.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_DELAY_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_delay_popup USING
    iv_flight     TYPE zstr_flight_data
    iv_probability TYPE f.

  DATA: lv_text1   TYPE string,
        lv_text2   TYPE string,
        lv_percent TYPE string,
        lv_answer  TYPE c.

  " uçuş yönü
  lv_text1 = |Uçuş: { iv_flight-dep_airport } → { iv_flight-arr_airport }|.

  " Gecikme oranı + saat ve havayolu bilgisi birleştirilerek 2. satıra yazılır
  lv_percent = |{ iv_probability * 100 DECIMALS = 1 }|.
  lv_text2 = |Saat: { iv_flight-dep_time } / Havayolu: { iv_flight-airline } / Gecikme: %{ lv_percent }|.

  " Popup fonksiyonu (SADECE desteklenen parametrelerle!)
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      titel         = 'Tahmini Gecikme'
      diagnosetext1 = 'Seçilen uçuş bilgileri aşağıdadır.'
      textline1     = lv_text1
      textline2     = lv_text2
      start_column  = 10
      start_row     = 5
    IMPORTING
      answer        = lv_answer.

  "Kullanıcının popup yanıtına göre hareket
  CASE lv_answer.
    WHEN 'J'. " Yes → Devam et
      SET SCREEN 0300.
      LEAVE SCREEN.

    WHEN 'A' OR 'C'. " No / Cancel / Çarpı → hiçbir şey yapma
      " popup kapanır, aynı ekranda kalır
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form FILL_FORM_DROPDOWN
*&---------------------------------------------------------------------*
*& Ekrandaki ünvan dropdown'unu doldurur.
*&---------------------------------------------------------------------*
FORM fill_form_dropdown.

  DATA: lt_form_vals TYPE vrm_values,
        ls_form_val  TYPE vrm_value.

  CLEAR lt_form_vals.

  ls_form_val-key  = 'bay'.
  ls_form_val-text = 'bay.'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'bayan'.
  ls_form_val-text = 'bayan.'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'NON'.
  ls_form_val-text = 'belirtmiyorum.'.
  APPEND ls_form_val TO lt_form_vals.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_FORM'
      values = lt_form_vals.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_CUSTOMER_TO_TABLE
*&---------------------------------------------------------------------*
*& Yolcu bilgilerini kontrol edip geçici tabloya ekler.
*&---------------------------------------------------------------------*
FORM append_customer_to_table.

  DATA: lv_max_id TYPE zpp_scustom-id.

  CONSTANTS: c_illegal_chars_city  TYPE string VALUE '0123456789<>/?!@#$%^&*()_+=-[]{}|',
             c_illegal_chars_phone TYPE string VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz<>/?!@#$%^&*()_+=-[]{}|',
             c_illegal_chars_email TYPE string VALUE ' ',
             c_min_city_len        TYPE i VALUE 3.

  IF gv_name IS INITIAL OR gv_surname IS INITIAL OR
     gv_city IS INITIAL OR gv_phone IS INITIAL OR
     gv_email IS INITIAL OR gv_birthdate IS INITIAL.
    MESSAGE 'Lütfen tüm alanları doldurun!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_phone CA c_illegal_chars_phone.
    MESSAGE 'Telefon numarası sadece rakamlardan oluşmalıdır!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_city CA c_illegal_chars_city.
    MESSAGE 'Şehir ismi rakam veya özel karakter içeremez!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF strlen( gv_city ) < c_min_city_len.
    MESSAGE 'Şehir ismi çok kısa! En az 3 karakter giriniz.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF NOT ( gv_email CS '@' AND gv_email CS '.' ).
    MESSAGE 'Geçerli bir e-posta adresi giriniz!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_birthdate > sy-datum.
    MESSAGE 'Doğum tarihi bugünden sonraki bir tarih olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SELECT MAX( id ) INTO lv_max_id FROM zpp_scustom.
  gs_customer-id = lv_max_id + 1.

  gs_customer-name      = gv_name.
  gs_customer-surname   = gv_surname.
  gs_customer-form      = gv_form.
  gs_customer-city      = gv_city.
  gs_customer-telephone = gv_phone.
  gs_customer-email     = gv_email.
  gs_customer-passbirth = gv_birthdate.

  APPEND gs_customer TO gt_customers.
  CLEAR gs_customer.

  MESSAGE |{ gv_name } { gv_surname } başarıyla eklendi.| TYPE 'S'.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form SAVE_BOOKING
*&---------------------------------------------------------------------*
*& Verilen müşteri için uçuş rezervasyonu oluşturur.
*&---------------------------------------------------------------------*
*&      --> iv_customer : zpp_scustom tipinde müşteri verisi
*&---------------------------------------------------------------------*
FORM save_booking.

  DATA: ls_customer     TYPE zpp_scustom,
        ls_flight       TYPE zpp_sflight,
        ls_booking      TYPE zpp_sbook,
        lv_bookid       TYPE zpp_sbook-bookid,
        lv_ticket_code  TYPE string,
        lv_mail_success TYPE abap_bool,
        lv_mail_msg     TYPE string,
        lv_fldate_str   TYPE string,
        lv_fldate_dats  TYPE sy-datum,
        lv_duration     TYPE string,
        ls_cityfrom_txt TYPE vrm_value,
        ls_cityto_txt   TYPE vrm_value,
        lv_popup_ans    TYPE c.

  lv_fldate_str = gs_selected_flight-dep_time+0(4) &&
                  gs_selected_flight-dep_time+5(2) &&
                  gs_selected_flight-dep_time+8(2).
  lv_fldate_dats = lv_fldate_str.

  READ TABLE gt_cityfrom_vals INTO ls_cityfrom_txt WITH KEY key = gv_cityfrom.
  READ TABLE gt_cityto_vals   INTO ls_cityto_txt   WITH KEY key = gv_cityto.

  lv_duration = gs_selected_flight-duration.
  REPLACE ALL OCCURRENCES OF 'PT' IN lv_duration WITH ''.
  REPLACE ALL OCCURRENCES OF 'H'  IN lv_duration WITH 's '.
  REPLACE ALL OCCURRENCES OF 'M'  IN lv_duration WITH 'dk'.

  SELECT SINGLE * INTO ls_flight FROM zpp_sflight
    WHERE carrid = gs_selected_flight-airline
      AND connid = gs_selected_flight-flight_id
      AND fldate = lv_fldate_dats.

  IF sy-subrc <> 0.
    CLEAR ls_flight.
    ls_flight-carrid       = gs_selected_flight-airline.
    ls_flight-connid       = gs_selected_flight-flight_id.
    ls_flight-fldate       = lv_fldate_dats.
    ls_flight-price        = gs_selected_flight-price.
    ls_flight-currency     = gs_selected_flight-currency.
    ls_flight-cityfrom     = ls_cityfrom_txt-text.
    ls_flight-cityto       = ls_cityto_txt-text.
    ls_flight-deptime      = gs_selected_flight-dep_time.
    ls_flight-arrtime      = gs_selected_flight-arr_time.
    ls_flight-duration     = lv_duration.
    ls_flight-dep_airport  = gv_cityfrom.
    ls_flight-arr_airport  = gv_cityto.

    INSERT zpp_sflight FROM ls_flight.
  ENDIF.

  LOOP AT gt_customers INTO ls_customer.

    INSERT zpp_scustom FROM ls_customer.

    SELECT MAX( bookid ) INTO lv_bookid FROM zpp_sbook.
    lv_bookid = lv_bookid + 1.

    PERFORM generate_ticket_code CHANGING lv_ticket_code.

    ls_booking-bookid     = lv_bookid.
    ls_booking-carrid     = gs_selected_flight-airline.
    ls_booking-connid     = gs_selected_flight-flight_id.
    ls_booking-fldate     = lv_fldate_dats.
    ls_booking-customid   = ls_customer-id.
    ls_booking-order_date = sy-datum.
    ls_booking-passname   = |{ ls_customer-name } { ls_customer-surname }|.
    ls_booking-passform   = ls_customer-form.
    ls_booking-passbirth  = ls_customer-passbirth.
    ls_booking-class      = 'Y'.
    ls_booking-invoice    = 'X'.
    ls_booking-ticketcode = lv_ticket_code.
    ls_booking-price      = gs_selected_flight-price.
    ls_booking-loccurkey  = gs_selected_flight-currency.

    INSERT zpp_sbook FROM ls_booking.

    CALL FUNCTION 'Z_FM_SEND_CONFIRMATION_MAIL'
      EXPORTING
        iv_email   = |{ ls_customer-email }|
        iv_code    = lv_ticket_code
      IMPORTING
        ev_success = lv_mail_success
        ev_message = lv_mail_msg.

    IF lv_mail_success = abap_false.
      MESSAGE |{ ls_customer-name } için mail gönderilemedi: { lv_mail_msg }| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      titel         = 'Rezervasyon Tamamlandı'
      diagnosetext1 = 'Tüm yolcular başarıyla kaydedildi.'
      textline1     = 'Bilet kodları mail olarak gönderildi.'
      textline2     = 'Havalimanında bu kodları kullanabilirsiniz.'
    IMPORTING
      answer        = lv_popup_ans.

  IF lv_popup_ans = '1'.
    LEAVE TO SCREEN '0100'.
  ENDIF.

ENDFORM.





*&---------------------------------------------------------------------*
*& Form HANDLE_BACK_ACTION
*&---------------------------------------------------------------------*
*& Geri butonuna basıldığında bir önceki kişiye döner ya da
*& ilk yolcudaysa uçuş seçimine yönlendirir.
*&---------------------------------------------------------------------*
FORM handle_back_action.

  IF gv_current_person > 1.

    SUBTRACT 1 FROM gv_current_person.

    READ TABLE gt_customers INTO gs_customer INDEX gv_current_person.
    IF sy-subrc = 0.
      gv_name       = gs_customer-name.
      gv_surname    = gs_customer-surname.
      gv_form       = gs_customer-form.
      gv_city       = gs_customer-city.
      gv_phone      = gs_customer-telephone.
      gv_email      = gs_customer-email.
      gv_birthdate  = gs_customer-passbirth. "

      DELETE gt_customers INDEX gv_current_person.
    ENDIF.

    LEAVE TO SCREEN '0300'.

  ELSE.

    CLEAR: gt_customers[],
           gv_current_person,
           gv_passenger_count,
           gv_name, gv_surname, gv_form, gv_city,
           gv_phone, gv_email, gv_birthdate. "

    MESSAGE 'Uçuş seçimine dönülüyor. Yolcu bilgileri sıfırlandı.' TYPE 'I'.
    LEAVE TO SCREEN '0200'.

  ENDIF.

ENDFORM.


FORM generate_ticket_code CHANGING ev_code TYPE string.

  DATA: lv_length TYPE i VALUE 6,
        lv_chars  TYPE string VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
        lv_index  TYPE i,
        lv_offset TYPE i,
        lv_char   TYPE c LENGTH 1.

  CLEAR ev_code.

  DO lv_length TIMES.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max = strlen( lv_chars )
        ran_int_min = 1
      IMPORTING
        ran_int     = lv_index.

    lv_offset = lv_index - 1.
    lv_char = lv_chars+lv_offset(1).

    CONCATENATE ev_code lv_char INTO ev_code.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_verification_code.
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_verification_code.

  DATA: lv_found    TYPE zpp_sbook-bookid,
        lv_success  TYPE abap_bool,
        lv_msg      TYPE string,
        lv_rand     TYPE i,
        lv_customid TYPE zpp_scustom-id.

  " Alanlar dolu mu?
  IF gv_cancel_email IS INITIAL OR gv_cancel_ticket_code IS INITIAL.
    MESSAGE 'Lütfen e-posta ve bilet kodunu giriniz.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Email ve ticketcode eşleşiyor mu?
  SELECT SINGLE s~bookid c~id
    INTO (lv_found, lv_customid)
    FROM zpp_sbook AS s
    INNER JOIN zpp_scustom AS c ON s~customid = c~id
    WHERE s~ticketcode = gv_cancel_ticket_code
      AND c~email      = gv_cancel_email.

  IF sy-subrc <> 0.
    MESSAGE 'Girilen e-posta ve bilet kodu eşleşmiyor!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Kod üret
  CALL FUNCTION 'QF05_RANDOM_INTEGER'
    EXPORTING
      ran_int_max = 999999
      ran_int_min = 100000
    IMPORTING
      ran_int     = lv_rand.

  gv_sent_code = lv_rand.

  " Mail gönder
  CALL FUNCTION 'Z_FM_SEND_CANCEL_CODE'
    EXPORTING
      iv_email       = gv_cancel_email
      iv_ticket_code = gv_cancel_ticket_code
      iv_code        = gv_sent_code
    IMPORTING
      ev_success     = lv_success
      ev_message     = lv_msg.

  IF lv_success = abap_false.
    MESSAGE lv_msg TYPE 'E'.
    RETURN.
  ENDIF.

  " Kod ekranına geç
  CLEAR: gv_user_code.
  gv_attempt_count = 0.
  CALL SCREEN 0110.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_CUSTOMER_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_customer_data.

  DATA: lv_customid TYPE zpp_scustom-id,
        ls_customer TYPE zpp_scustom,
        lt_booking  TYPE TABLE OF zpp_sbook,
        ls_booking  TYPE zpp_sbook.

  " 1. Ticketcode üzerinden müşteri ID'sini al
  SELECT SINGLE customid
    INTO lv_customid
    FROM zpp_sbook
    WHERE ticketcode = gv_cancel_ticket_code.

  IF sy-subrc <> 0.
    MESSAGE 'Bu ticket koduna ait müşteri bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 2. Müşteri kaydını al
  SELECT SINGLE * INTO ls_customer
    FROM zpp_scustom
    WHERE id = lv_customid.

  IF sy-subrc <> 0.
    MESSAGE 'Müşteri kaydı bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 3. Yeni bilgileri müşteri kaydına aktar
  ls_customer-name      = gv_updte_name.
  ls_customer-surname   = gv_updte_surname.
  ls_customer-city      = gv_updte_city.
  ls_customer-telephone = gv_updte_phone.
  ls_customer-form      = gv_updte_form.
  ls_customer-passbirth = gv_updte_birthdate.

  " 4. SCUSTOM tablosunu güncelle
  UPDATE zpp_scustom FROM ls_customer.

  IF sy-subrc <> 0.
    MESSAGE 'Müşteri bilgileri güncellenemedi!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 5. SBOOK tablosundaki ilgili kayıtları güncelle
  SELECT * INTO TABLE lt_booking
    FROM zpp_sbook
    WHERE customid = lv_customid.

  LOOP AT lt_booking INTO ls_booking.
    ls_booking-passname  = |{ ls_customer-name } { ls_customer-surname }|.
    ls_booking-passform  = ls_customer-form.
    ls_booking-passbirth = ls_customer-passbirth.
    MODIFY zpp_sbook FROM ls_booking.
  ENDLOOP.

  MESSAGE 'Müşteri ve rezervasyon bilgileri başarıyla güncellendi.' TYPE 'S'.
  LEAVE TO SCREEN 0100.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form FILL_FORM_DROPDOWN_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_form_dropdown_update .
  DATA: lt_form_vals TYPE vrm_values,
        ls_form_val  TYPE vrm_value.

  CLEAR lt_form_vals.

  ls_form_val-key  = 'bay'.
  ls_form_val-text = 'bay.'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'bayan'.
  ls_form_val-text = 'bayan.'.
  APPEND ls_form_val TO lt_form_vals.

  ls_form_val-key  = 'NON'.
  ls_form_val-text = 'belirtmiyorum.'.
  APPEND ls_form_val TO lt_form_vals.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_UPDTE_FORM'  "  Güncelleme ekranına göre düzeltildi
      values = lt_form_vals.
ENDFORM.
