CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_buffer,
             flag    TYPE c LENGTH 5,       " 'C' = Create, 'U' = Update, 'D' = Delete
             lv_data TYPE zsoa_elt_0005,   " The structure that holds ledger data
           END OF ty_buffer.

    CLASS-DATA mt_buffer TYPE STANDARD TABLE OF ty_buffer WITH EMPTY KEY.  " Table to store buffer entries

    " Method to get an instance of the buffer class (Singleton pattern)
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.
    METHODS job_data_create
      IMPORTING
        iv_run_uuid TYPE sysuuid_x16 OPTIONAL
        iv_bukrs    TYPE bukrs OPTIONAL
        iv_gjahr    TYPE gjahr OPTIONAL
        iv_rldnr    TYPE fins_ledger OPTIONAL
        iv_monat    TYPE monat OPTIONAL.
    " Method to add records to the buffer (Create, Update, or Delete)
    METHODS add_to_buffer
      IMPORTING
        iv_flag     TYPE c         " Flag to specify the type of operation (C/U/D)
        is_ledger TYPE zsoa_elt_0005.  " ledger data to be added to the buffer
    METHODS check_create_to_buffer
      IMPORTING
        iv_flag     TYPE c         " Flag to specify the type of operation (C/U/D)
        is_ledger TYPE zsoa_elt_0005.  " ledger data to be added to the buffer
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_buffer.  " Holds the single instance of the class
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.
  METHOD check_create_to_buffer.

  ENDMETHOD.
  METHOD job_data_create.


  ENDMETHOD.
  METHOD add_to_buffer.
    INSERT VALUE #( flag = iv_flag lv_data = is_ledger ) INTO TABLE mt_buffer.
  ENDMETHOD.

ENDCLASS.

" Custom Exception Class
CLASS zcx_my_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_message.  " This interface is used for handling messages.
    METHODS constructor IMPORTING
                          textid LIKE if_t100_message=>t100key OPTIONAL.  " Constructor to initialize exception with a message
ENDCLASS.

CLASS zcx_my_exception IMPLEMENTATION.
  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.   " Calling the parent class constructor
    me->if_t100_message~t100key = textid.  " Set the error message key
  ENDMETHOD.
ENDCLASS.





CLASS lhc_zi_soa_el_0005 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_soa_el_0005 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_soa_el_0005 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_soa_el_0005 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_soa_el_0005.

    METHODS cancdoc FOR MODIFY
      IMPORTING keys FOR ACTION zi_soa_el_0005~cancdoc.

ENDCLASS.

CLASS lhc_zi_soa_el_0005 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.


      SELECT  runuuid     AS runuuid,
    item,
  bukrs               ,
  gjahr                ,

  monat,
  STATUS
 FROM ZI_SOA_EL_0002
 FOR ALL ENTRIES IN @keys
 WHERE  runuuid    =  @keys-runuuid
   INTO TABLE @DATA(lt_mult).

    result = CORRESPONDING #( lt_mult ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD cancdoc.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
*
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      SELECT SINGLE *
    FROM zsoa_elt_0001
    WHERE run_uuid EQ @<ls_key>-runuuid
     INTO @DATA(ls_t01).
      " 1️⃣ DB'den mevcut kaydı oku
      SELECT SINGLE status
        FROM zsoa_elt_0001
       WHERE bukrs = @ls_t01-bukrs
               AND monat > @ls_t01-monat
               AND gjahr = @ls_t01-gjahr
               AND  status = '3'
        INTO @DATA(lv_status).
      IF sy-subrc IS INITIAL.

        " Silmeyi engelle
        APPEND VALUE #(
          %tky = <ls_key>-%tky
        ) TO failed-zi_soa_el_0005.

        " Mesaj dön
        APPEND VALUE #(
          %tky = <ls_key>-%tky
          %msg = new_message(
                   id       = 'ZEL_MSG'
                   number   = '011'
                   severity = if_abap_behv_message=>severity-error
                 )
        ) TO reported-zi_soa_el_0005.

        CONTINUE.
      ENDIF.


      DATA ls_LEDGER TYPE zsoa_elt_0005.
      ls_LEDGER-run_uuid = <ls_key>-runuuid.
**       ls_employee-gjahr = <ls_key>-.
      lo_buffer->add_to_buffer( iv_flag = 'CANC' is_ledger = ls_LEDGER ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_soa_el_0005 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_soa_el_0005 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
   DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT lo_buffer->mt_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).
      CASE <ls_buf>-flag.


        WHEN 'CANC'.
          UPDATE zsoa_elt_0001 SET status = '2' WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
*          DELETE FROM zsoa_elt_0002 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
          DELETE FROM zsoa_elt_0005 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
*            DELETE FROM zsoa_elt_0004 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
      ENDCASE.
    ENDLOOP.
    CLEAR lo_buffer->mt_buffer.  " Clear the buffer after saving changes
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
