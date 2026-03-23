CLASS zcl_soa_el_data_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    DATA: gr_log TYPE REF TO if_bali_log.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS set_message
      IMPORTING
        iv_msgtx TYPE cl_bali_free_text_setter=>ty_text
        iv_type  TYPE if_bali_constants=>ty_severity.
ENDCLASS.



CLASS ZCL_SOA_EL_DATA_CREATE IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

    et_parameter_def = VALUE #(
       kind           = if_apj_dt_exec_object=>select_option
       changeable_ind = abap_true
       ( selname    = 'IV_RUNID'
         param_text = 'Run Id'
         datatype   = 'C'
         length     = 36 )        " select-option

       ( selname    = 'IV_BUKRS'
         param_text = 'Şirket Kodu'
         datatype   = 'C'
         length     = 4 )
          ( selname    = 'IV_GJAHR'
         param_text = 'Yıl'
         datatype   = 'N'
         length     = 4 )

          ( selname    = 'IV_MONAT'
         param_text = 'Ay'
         datatype   = 'N'
         length     = 2 ) ).


  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA : BEGIN OF gs_key,
             run_uuid TYPE sysuuid_x16,
             bukrs    TYPE bukrs,
             gjahr    TYPE gjahr,
             rldnr    TYPE fins_ledger,
             monat    TYPE monat,
           END OF gs_key.
    DATA: ls_d TYPE ztest_el .
*    data: lv_uuid_x16 TYPE sysuuid_x16.
    set_message( iv_msgtx = 'Job Başladı.' iv_type = 'I' ).
*        delete fROM  ztest_el.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      set_message( iv_msgtx = |PARAMETRE: { ls_parameter-selname },{ ls_parameter-low },{ ls_parameter-high }| iv_type = 'I' ).
      CASE ls_parameter-selname.
        WHEN 'IV_RUNID'.
*          gs_key-run_uuid =  ls_parameter-low.
*          ls_d-run_uuid =  gs_key-run_uuid .
*          ls_d-run_uuidc = gs_key-run_uuid .
*          ls_d-run_uuidc1 = ls_parameter-low.
*          ls_d-run_uuidc2 = ls_parameter-low.
        WHEN 'IV_BUKRS'.
          gs_key-bukrs =  ls_parameter-low.
        WHEN 'IV_GJAHR'.
          gs_key-gjahr =  ls_parameter-low.
        WHEN 'IV_MONAT'.
          gs_key-monat =  ls_parameter-low.
      ENDCASE.
    ENDLOOP.
    SELECT SINGLE run_uuid
    FROM zsoa_elt_0001
    WHERE bukrs EQ @gs_key-bukrs
      AND gjahr EQ @gs_key-gjahr
      AND monat EQ @gs_key-monat
      INTO @gs_key-run_uuid .
      if sy-subrc is iNITIAL.
       set_message( iv_msgtx = |PARAMETRE: IV_RUNID,{  gs_key-run_uuid  }| iv_type = 'I' ).
      eNDIF.
 DELETE FROM zsoa_elt_0002 wHERE   bukrs   EQ @gs_key-bukrs
   and gjahr    EQ @gs_key-gjahr
    and monat eq @gs_key-monat .

delete fROM zsoa_elt_0004 wHERE   bukrs   EQ @gs_key-bukrs
   and gjahr    EQ @gs_key-gjahr
    and rldnr    = '0L'
    and monat eq @gs_key-monat .
zcl_soa_el_create=>get_instance(
  EXPORTING
    iv_run_uuid = gs_key-run_uuid
    iv_bukrs    = gs_key-bukrs
    iv_gjahr    = gs_key-gjahr
    iv_rldnr    = '0L'
    iv_monat    = gs_key-monat
  IMPORTING
    r_instance  = DATA(ro_instance)
).

ro_instance->call_for_DATA(
  RECEIVING
    rt_err =  DATA(lv_err)
).
*
    set_message( iv_msgtx = 'Job Bitti.' iv_type = 'I' ).
  ENDMETHOD.


  METHOD set_message.

    DATA(ls_message) = cl_bali_free_text_setter=>create(
        severity = iv_type
        text = iv_msgtx ).

    "Log objesini aldı
    TRY.
        IF gr_log IS INITIAL.
          gr_log = cl_bali_log=>create_with_header(
              header = cl_bali_header_setter=>create(
                  object = 'ZSOALO_DATA_CREATE'
                  subobject = 'ZLO_DATA_CREATE_IN' ) ).
        ENDIF.
      CATCH cx_bali_runtime.
    ENDTRY.

    TRY.
        gr_log->add_item( item = ls_message ).
      CATCH cx_bali_runtime.
    ENDTRY.

    "Job mesajını sisteme işledi
    TRY.
        cl_bali_log_db=>get_instance( )->save_log(
            log = gr_log
            assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime..
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
