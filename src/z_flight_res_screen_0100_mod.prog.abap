*----------------------------------------------------------------------*
***INCLUDE Z_FLIGHT_RES_SCREEN_0100_MOD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  PERFORM fill_cityfrom_dropdown.
  PERFORM fill_cityto_dropdown.
  SET PF-STATUS '0200'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&BCK'.
       LEAVE PROGRAM.

    WHEN '&SRCH'.
      PERFORM search_flight.


    WHEN '&DLTE'.
      gv_is_update = abap_false.
      PERFORM send_verification_code.
    WHEN '&UPD_INFO'.
      gv_is_update = abap_true.


      PERFORM send_verification_code.


    WHEN '&EXIT'.  " Çıkış
       LEAVE PROGRAM.



  ENDCASE.

ENDMODULE.
