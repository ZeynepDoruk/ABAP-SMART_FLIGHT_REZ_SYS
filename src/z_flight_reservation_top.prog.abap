*&---------------------------------------------------------------------*
*& Include          Z_FLIGHT_RESERVATION_TOP
*&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_double_click
                  FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column sender.
ENDCLASS.

"  Şehir ve tarih bilgileri
DATA: gv_cityfrom        TYPE spfli-cityfrom,      " Kalkış şehri
      gv_cityto          TYPE spfli-cityto,        " Varış şehri
      gv_flight_date     TYPE zpp_sflight-fldate,  " Uçuş tarihi
      gv_passenger_count TYPE i.                   " Yolcu sayısı

" Dropdown verileri
DATA: gv_id_cityfrom   TYPE vrm_id,
      gv_id_cityto     TYPE vrm_id,
      gt_cityfrom_vals TYPE vrm_values,
      gt_cityto_vals   TYPE vrm_values,
      gs_city_value    TYPE vrm_value.

" Şehir veri tipleri
TYPES: BEGIN OF ty_cityfrom,
         cityfrom TYPE spfli-cityfrom,
         airpfrom TYPE spfli-airpfrom,
       END OF ty_cityfrom.

TYPES: BEGIN OF ty_cityto,
         cityto TYPE spfli-cityto,
         airpto TYPE spfli-airpto,
       END OF ty_cityto.

DATA: lt_cityfrom TYPE STANDARD TABLE OF ty_cityfrom,
      ls_cityfrom TYPE ty_cityfrom,
      lt_cityto   TYPE STANDARD TABLE OF ty_cityto,
      ls_cityto   TYPE ty_cityto.
TYPES: ty_airport_code TYPE spfli-airpfrom.
DATA : lt_common_airports TYPE STANDARD TABLE OF ty_airport_code WITH EMPTY KEY.


" Genel hata mesajı
DATA: gv_error_message TYPE string.

" ALV ve uçuş listesi
DATA: gt_flights         TYPE ztt_flight_data,
      alv_grid           TYPE REF TO cl_gui_alv_grid,
      alv_container      TYPE REF TO cl_gui_custom_container,
      gr_handler         TYPE REF TO lcl_event_handler,
      gs_selected_flight TYPE zstr_flight_data.

" Gecikme tahmini
DATA: gv_probability TYPE f,
      gv_delay_error TYPE string.

" Modelin desteklediği havayolları
DATA: lt_supported_airlines TYPE STANDARD TABLE OF zpp_scarr-carrid WITH DEFAULT KEY,
      lt_filtered           TYPE ztt_flight_data,
      ls_flight             TYPE zstr_flight_data.

" ALV başlıkları
DATA: it_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat TYPE lvc_s_fcat.

" Yolcu bilgileri - Tekil
DATA: gv_id        TYPE zpp_scustom-id,
      gv_name      TYPE zpp_scustom-name,
      gv_form      TYPE zpp_scustom-form,
      gv_city      TYPE zpp_scustom-city,
      gv_phone     TYPE zpp_scustom-telephone,
      gv_email     TYPE zpp_scustom-email,
      gv_surname   TYPE zpp_scustom-surname,
      gv_birthdate TYPE zpp_sflight-fldate. "

"  Çoklu yolcu yönetimi için yeni alanlar
DATA: gv_current_person TYPE i VALUE 1,                    " Şu anki kişi numarası
      gv_passenger_text TYPE char50,                       " '1. Yolcunun Bilgileri' gibi açıklama
      gt_customers      TYPE STANDARD TABLE OF zpp_scustom, " Geçici müşteri listesi
      gs_customer       TYPE zpp_scustom.                  " Tek müşteri kaydı


DATA: gv_cancel_email       TYPE string,
      gv_cancel_ticket_code TYPE string,
      gv_sent_code          TYPE string,
      gv_user_code          TYPE string,
      gv_attempt_count      TYPE i VALUE 0.

DATA: gv_remaining_attempt TYPE i.

DATA: gv_is_update TYPE abap_bool. " TRUE ise güncelleme işlemidir
DATA:
  gv_updte_name      TYPE zpp_scustom-name,
  gv_updte_form      TYPE zpp_scustom-form,
  gv_updte_city      TYPE zpp_scustom-city,
  gv_updte_phone     TYPE zpp_scustom-telephone,
  gv_updte_email     TYPE zpp_scustom-email,
  gv_updte_surname   TYPE zpp_scustom-surname,
  gv_updte_birthdate TYPE zpp_sflight-fldate. "
