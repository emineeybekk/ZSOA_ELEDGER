CLASS zcl_soa_el_control DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_fin_re_custom_function .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES : ty_fiscalyear   TYPE i_journalentry-fiscalyear,
            ty_POSTINGDATE TYPE i_journalentry-POSTINGDATE,
            ty_companycode  TYPE i_journalentry-companycode.
    TYPES : BEGIN OF ty_parameter ,
              name  TYPE fin_re_rule_parameter_name,
              value TYPE REF TO data,
            END OF ty_parameter,
            tty_runtime_parameters TYPE STANDARD TABLE OF ty_parameter WITH EMPTY KEY
                                           WITH UNIQUE SORTED KEY p COMPONENTS name.

    TYPES: ty_return TYPE c LENGTH 1.

    CONSTANTS: c_function_name TYPE fin_re_custom_function_name VALUE 'ZFI_ELEDGER_CONTROL',
               c_fiscalyear    TYPE c LENGTH 10 VALUE 'FISCALYEAR',
               c_POSTINGDATE  TYPE c LENGTH 12 VALUE 'POSTINGDATE',
               c_companycode   TYPE c LENGTH 11 VALUE 'COMPANYCODE'.


ENDCLASS.



CLASS ZCL_SOA_EL_CONTROL IMPLEMENTATION.


  METHOD if_fin_re_custom_function~check_at_rule_activation.
    ev_rc = if_fin_re_custom_function=>rc-ok.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~execute.
    "Doğrulamanın kontrol edildiği yer

    TYPES : BEGIN OF ts_param_values,
              companycode  TYPE ty_companycode,
              POSTINGDATE TYPE ty_POSTINGDATE,
              fiscalyear   TYPE ty_fiscalyear,
            END OF ts_param_values.

    DATA : lt_parameters   TYPE tty_runtime_parameters,
           ls_param_values TYPE ts_param_values,
           lv_dats         TYPE datum,
           lv_monat type monat.
    lt_parameters = CORRESPONDING #( is_runtime-parameters ) .
    IF is_runtime-rule_name = 'ZFI_ELEDGER_CONTROL' OR is_runtime-rule_name = 'ZFI_ELEDGER_CONTROL_RV'.
      .
      READ TABLE lt_parameters WITH KEY p COMPONENTS name = c_companycode INTO DATA(ls_param).
      IF ls_param-value IS BOUND AND ls_param-value IS NOT INITIAL.
        ls_param_values-companycode  = ls_param-value->*.

      ENDIF.

      READ TABLE lt_parameters WITH KEY p COMPONENTS name = c_POSTINGDATE INTO ls_param.
      IF ls_param-value IS BOUND AND ls_param-value IS NOT INITIAL.
*        ls_param_values-fiscalperiod = ls_param-value->*.
        lv_dats =  ls_param-value->*..
         lv_monat  = lv_dats+4(2).
      ENDIF.

      READ TABLE lt_parameters WITH KEY p COMPONENTS name = c_fiscalyear INTO ls_param.
      IF ls_param-value IS BOUND AND ls_param-value IS NOT INITIAL.
        ls_param_values-fiscalyear = ls_param-value->*.

      ENDIF.
      IF ls_param_values-companycode IS NOT INITIAL.
        SELECT SINGLE *
         FROM zsoa_elt_0001
           WITH PRIVILEGED ACCESS
         WHERE  bukrs     EQ @ls_param_values-companycode
           AND  gjahr     EQ @ls_param_values-fiscalyear
           AND  monat      EQ @lv_monat
           AND  status     EQ '3'
         INTO @DATA(ls_el1).
        IF  sy-subrc IS INITIAL.
          ev_result = REF #( abap_false ).

        ELSE.
          ev_result = REF #( abap_true ).
        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_description.
    "Doğrulama Adı
    rs_msg = VALUE symsg( msgid = 'ZEL_MSG' msgno = '012' ).
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_name.
    rv_name = c_function_name.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_parameters.
    "Doğrulamaya giden dinamik parametreler
    rt_parameters = VALUE #(

  ( name = c_companycode  abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZCL_SOA_EL_CONTROL=>TY_COMPANYCODE' ) ) )
     ( name = c_POSTINGDATE  abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZCL_SOA_EL_CONTROL=>TY_POSTINGDATE' ) ) )
     ( name = c_fiscalyear  abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZCL_SOA_EL_CONTROL=>TY_FISCALYEAR' ) ) )
      ).
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_returntype.
    "Return type zorunlu yoksa uyarlamada error yiyor
    ro_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZCL_SOA_EL_CONTROL=>TY_RETURN' ) ).
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_return_valuehelp.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~is_disabled.
    rv_disable = abap_false.
  ENDMETHOD.
ENDCLASS.
