*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_REZ_ADMIN_0400_MOD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0400 OUTPUT.
*
  SET PF-STATUS '0300'.
  LOOP AT SCREEN.

    CASE tb_id-activetab.
      WHEN '&TAB1'.
        IF screen-name = 'SUB1'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-name CP 'SUB*'.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.

      WHEN '&TAB2'.
        IF screen-name = 'SUB2'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-name CP 'SUB*'.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.

      WHEN '&TAB3'.
        IF screen-name = 'SUB3'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-name CP 'SUB*'.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.

      WHEN '&TAB4'.
        IF screen-name = 'SUB4'.
          screen-invisible = 0.
          screen-active = 1.
        ELSEIF screen-name CP 'SUB*'.
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.

    ENDCASE.



    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CASE sy-ucomm.
    WHEN '&TAB1' OR '&TAB2' OR '&TAB3' OR '&TAB4'.
      tb_id-activetab = sy-ucomm.
    WHEN '&EXT'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.



*&---------------------------------------------------------------------*
*& Module STATUS_0410 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0410 OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'SUB5'.
      IF gv_show_alv = abap_true.
        screen-invisible = 0.
        screen-active    = 1.
      ELSE.
        screen-invisible = 1.
        screen-active    = 0.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0410  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0410 INPUT.
  CASE sy-ucomm.
    WHEN '&ADD_FLIGHT'.
      PERFORM add_flight.

    WHEN '&_UPD_FLIGHT'.
      PERFORM update_flight.
    WHEN '&DEL_FLIGHT'.
      PERFORM delete_flight.
    WHEN '&_LIST_FLIGHT'.
      gv_show_alv = abap_true.
      PERFORM list_flights.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0420 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0420 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  LOOP AT SCREEN.
    IF screen-name = 'SUB6'.
      IF gv_show_alv_cust = abap_true.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0420  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0420 INPUT.

  CASE sy-ucomm.

    WHEN '&LIST_CUST'.
      gv_show_alv_cust = abap_true.
      PERFORM fill_customer_alv.

  ENDCASE.


ENDMODULE.



*&---------------------------------------------------------------------*
*& Module STATUS_0430 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0430 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'

  LOOP AT SCREEN.
    IF screen-name = 'SUB7'.
      IF gv_show_alv_booking = abap_true.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0430  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0430 INPUT.

  CASE sy-ucomm.
    WHEN '&SHOWB'.
      gv_show_alv_booking = abap_true.
      PERFORM fill_booking_alv.

  ENDCASE.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0440 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0440 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  LOOP AT SCREEN.
    IF screen-name = 'SUB8'.
      IF gv_show_alv_del = abap_true.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0440 INPUT.


  CASE sy-ucomm.

    WHEN '&LIST_DEL'.
      gv_show_alv_del = abap_true.
      PERFORM list_delete_requests.



    WHEN '&CONF_DEL'.
      PERFORM delete_selected_request.

  ENDCASE.

ENDMODULE.
