CLASS zcl_soa_el_messages DEFINITION
 PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message .

    CONSTANTS mc_err_part_spec LIKE textid VALUE '100' ##NO_TEXT.

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZEL_MSG',

      BEGIN OF bukrs_exists,
        msgid TYPE symsgid VALUE 'ZEL_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_RID',
        attr2 TYPE scx_attrname VALUE 'MV_BUKRS',
        attr3 TYPE scx_attrname VALUE 'MV_GJAHR',
        attr4 TYPE scx_attrname VALUE 'MV_MONAT',
      END OF bukrs_exists,


      BEGIN OF bukrs_cont,
        msgid TYPE symsgid VALUE 'ZEL_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_RID',
        attr2 TYPE scx_attrname VALUE 'MV_BUKRS',
        attr3 TYPE scx_attrname VALUE 'MV_GJAHR',
        attr4 TYPE scx_attrname VALUE 'MV_MONAT',
      END OF bukrs_cont,
      BEGIN OF gjahr_cont,
        msgid TYPE symsgid VALUE 'ZEL_MSG',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_RID',
        attr2 TYPE scx_attrname VALUE 'MV_BUKRS',
        attr3 TYPE scx_attrname VALUE 'MV_GJAHR',
        attr4 TYPE scx_attrname VALUE 'MV_MONAT',
      END OF gjahr_cont,
      BEGIN OF monat_cont,
        msgid TYPE symsgid VALUE 'ZEL_MSG',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'MV_RID',
        attr2 TYPE scx_attrname VALUE 'MV_BUKRS',
        attr3 TYPE scx_attrname VALUE 'MV_GJAHR',
        attr4 TYPE scx_attrname VALUE 'MV_MONAT',
      END OF monat_cont,
      BEGIN OF backmonat_cont,
        msgid TYPE symsgid VALUE 'ZEL_MSG',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'MV_RID',
        attr2 TYPE scx_attrname VALUE 'MV_BUKRS',
        attr3 TYPE scx_attrname VALUE 'MV_GJAHR',
        attr4 TYPE scx_attrname VALUE 'MV_MONAT',
      END OF backmonat_cont
      .


    METHODS constructor
      IMPORTING
        textid      LIKE if_t100_message=>t100key OPTIONAL
        attr1       TYPE string OPTIONAL
        attr2       TYPE string OPTIONAL
        attr3       TYPE string OPTIONAL
        attr4       TYPE string OPTIONAL
        mv_bankcode TYPE bankk OPTIONAL
        mv_bukrs    TYPE bukrs OPTIONAL
        severity    TYPE if_abap_behv_message=>t_severity OPTIONAL
        uname       TYPE syuname OPTIONAL.




    DATA:
      mv_attr1    TYPE string,
      mv_attr2    TYPE string,
      mv_attr3    TYPE string,
      mv_attr4    TYPE string,
      mv_bankcode TYPE bankk,
      mv_bukrs    TYPE bukrs.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SOA_EL_MESSAGES IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor(  previous = previous ) .

    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_bankcode              = mv_bankcode.
    me->mv_bukrs                 = mv_bukrs.
    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
