*&---------------------------------------------------------------------*
*& Include          Z_FLIGHT_REZ_ADMIN_TOP
*&---------------------------------------------------------------------*
*-------------------------------
* 0410 -
*------------------------------
CONTROLS: tb_id TYPE TABSTRIP.

DATA: gv_tabcode TYPE sy-ucomm. " Aktif sekmeyi tutar

*" 🛫 Uçuş bilgileri - ZPP_SFLIGHT yapısına uygun
DATA: gv_carrid     TYPE zpp_sflight-carrid,
      gv_connid     TYPE zpp_sflight-connid,
      gv_fldate     TYPE zpp_sflight-fldate,
      gv_price      TYPE zpp_sflight-price,
      gv_currency   TYPE zpp_sflight-currency,
      gv_cityfrom   TYPE zpp_sflight-cityfrom,
      gv_cityto     TYPE zpp_sflight-cityto,
      gv_deptime    TYPE zpp_sflight-deptime,
      gv_arrtime    TYPE zpp_sflight-arrtime,
      gv_dep_airport TYPE zpp_sflight-dep_airport,
      gv_arr_airport TYPE zpp_sflight-arr_airport,
      gv_duration   TYPE zpp_sflight-duration.


DATA: gr_alv_container_flight TYPE REF TO cl_gui_custom_container,
      gr_alv_grid_flight      TYPE REF TO cl_gui_alv_grid.

DATA: gs_flight TYPE zpp_sflight.  " tüm veriler tek değişkende
DATA: gv_show_alv TYPE abap_bool VALUE abap_false.


*-------------------------------
* 0420 - Müşteri ALV Filtresi
*-------------------------------

DATA: gv_flt_name     TYPE zpp_scustom-name,
      gv_flt_surname  TYPE zpp_scustom-surname,
      gv_flt_city     TYPE zpp_scustom-city,
      gv_flt_form     TYPE zpp_scustom-form,
      gv_flt_email    TYPE zpp_scustom-email.

DATA: gt_customers TYPE TABLE OF zpp_scustom,
      gs_customer  TYPE zpp_scustom.

CLASS cl_gui_custom_container DEFINITION LOAD.
CLASS cl_gui_alv_grid DEFINITION LOAD.

DATA: gr_alv_container TYPE REF TO cl_gui_custom_container,
      gr_alv_grid      TYPE REF TO cl_gui_alv_grid.
DATA: gv_show_alv_cust TYPE abap_bool VALUE abap_false.

*-------------------------------
* 0430 - Rezervasyon ALV Filtresi
*-------------------------------
DATA: gv_show_alv_booking TYPE abap_bool VALUE abap_false.

DATA: gv_flt_ticketcode TYPE zpp_sbook-ticketcode,
      gv_flt_carrid     TYPE zpp_sbook-carrid,
      gv_flt_connid     TYPE zpp_sbook-connid,
      gv_flt_fldate     TYPE zpp_sbook-fldate.

DATA: gt_bookings TYPE TABLE OF zpp_sbook,
      gs_booking  TYPE zpp_sbook.

CLASS cl_gui_custom_container DEFINITION LOAD.
CLASS cl_gui_alv_grid DEFINITION LOAD.

DATA: gr_book_container TYPE REF TO cl_gui_custom_container,
      gr_book_grid      TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------*
* 0440      *
*---------------------------------------------------------------*

" ALV veri tablosu ve log kaydı için yapı
DATA: gt_delete_log TYPE TABLE OF zpp_delete_req_l,
      gs_delete_log TYPE zpp_delete_req_l.

" Seçilen satırın indexi
DATA: gv_selected_index TYPE sy-tabix.

" ALV nesneleri
DATA: gr_alv_grid_del TYPE REF TO cl_gui_alv_grid,
      gr_container_del TYPE REF TO cl_gui_custom_container.

" Kullanıcı onayı
DATA: gv_confirm_answer TYPE c.

" ALV görünürlüğü kontrolü
DATA: gv_show_alv_del TYPE abap_bool VALUE abap_false.

" Log ekranında silme işlemi için detay alanlar (ekranın altında gösterilecekse)
DATA: gv_log_ticketcode TYPE zpp_sbook-ticketcode,
      gv_log_email      TYPE zpp_scustom-email,
      gv_log_reason     TYPE char100.
