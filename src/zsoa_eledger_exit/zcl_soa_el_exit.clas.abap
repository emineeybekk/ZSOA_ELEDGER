CLASS zcl_soa_el_exit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   METHODS user_exit_update_line_data  .
*               TABLES pt_edefter STRUCTURE zed_yevmiye_satir_s4
*                USING p_all_data TYPE  zed_yevmiye_genel_s4
*             CHANGING p_edefter  TYPE  zed_yevmiye_satir_s4.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SOA_EL_EXIT IMPLEMENTATION.


mETHOD user_exit_update_line_data.

eNDMETHOD.
ENDCLASS.
