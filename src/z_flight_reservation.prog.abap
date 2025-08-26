*&---------------------------------------------------------------------*
*& Report Z_FLIGHT_RESERVATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flight_reservation.

Include          Z_FLIGHT_RESERVATION_TOP.
INCLUDE Z_FLIGHT_RESERVATION_FORMS.
Include          Z_FLIGHT_RES_ALV_EVENTS.
INCLUDE Z_FLIGHT_RES_SCREEN_0100_MOD.
INCLUDE Z_FLIGHT_RES_SCREEN_0200_MOD.





START-OF-SELECTION.
  CALL SCREEN 0100.


INCLUDE z_flight_res_screen_0300_mod.

INCLUDE z_flight_res_screen_0110_mod.

INCLUDE z_flight_res_screen_0120_mod.
