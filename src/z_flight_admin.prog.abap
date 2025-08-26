*&---------------------------------------------------------------------*
*& Report Z_FLIGHT_ADMIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_FLIGHT_ADMIN.

INCLUDE Z_FLIGHT_REZ_ADMIN_TOP.
INCLUDE z_flight_rez_admin_0400_mod.

Include          Z_FLIGHT_REZ_ADMIN_FORMS.


START-OF-SELECTION.
call SCREEN '0400'.
