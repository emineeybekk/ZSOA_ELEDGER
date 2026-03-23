CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_buffer,
             flag    TYPE c LENGTH 5,       " 'C' = Create, 'U' = Update, 'D' = Delete
             lv_data TYPE zsoa_elt_0001,   " The structure that holds employee data
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
        is_employee TYPE zsoa_elt_0001.  " Employee data to be added to the buffer
    METHODS check_create_to_buffer
      IMPORTING
        iv_flag     TYPE c         " Flag to specify the type of operation (C/U/D)
        is_employee TYPE zsoa_elt_0001.  " Employee data to be added to the buffer
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
    CHECK: iv_bukrs IS NOT INITIAL.

    DATA  lv_job_text TYPE cl_apj_rt_api=>ty_job_text VALUE 'Tahsilat_Job'.
    DATA lv_template_name TYPE cl_apj_rt_api=>ty_template_name.

    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA ls_scheduling_info TYPE cl_apj_rt_api=>ty_scheduling_info.
    DATA ls_end_info TYPE cl_apj_rt_api=>ty_end_info.

    DATA lt_job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA ls_job_parameters TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA ls_value TYPE cl_apj_rt_api=>ty_value_range.

    DATA lv_jobname TYPE cl_apj_rt_api=>ty_jobname.
    DATA lv_jobcount TYPE cl_apj_rt_api=>ty_jobcount.

    DATA lv_status TYPE cl_apj_rt_api=>ty_job_status.
    DATA lv_statustext TYPE cl_apj_rt_api=>ty_job_status_text.

    DATA lv_txt TYPE string.
    DATA ls_ret TYPE bapiret2.

    " Choose the name of the existing job template.
    lv_template_name = 'ZSOAJCE_EL_DATA_CREATE'.



    CLEAR:ls_start_info,ls_scheduling_info,ls_end_info ,lt_job_parameters,ls_job_parameters,ls_value.
    lv_job_text = 'E-defter datajob' && iv_bukrs && iv_monat && iv_gjahr.
    " Start the job using a timestamp instead. This will start the job immediately but can have a delay depending on the current workload.
    GET TIME STAMP FIELD DATA(ls_ts1).
    " Add 1 hour
    DATA(ls_ts2) = cl_abap_tstmp=>add( tstmp = ls_ts1
                                       secs  = 5 ).

    ls_start_info-timestamp = ls_ts2.

    " Periodicity

    ls_scheduling_info-periodic_granularity = 'D'.
    ls_scheduling_info-periodic_value = 1.
    ls_scheduling_info-test_mode = abap_false.
    ls_scheduling_info-timezone = 'CET'.

    ls_end_info-type = 'NUM'.
    ls_end_info-max_iterations = '1'.


    ls_job_parameters-name = 'IV_RUNID'.
    ls_value-sign = 'I'.
    ls_value-option = 'EQ'.
    ls_value-low = iv_run_uuid.
    APPEND ls_value TO ls_job_parameters-t_value.

    APPEND ls_job_parameters TO lt_job_parameters.
    CLEAR ls_job_parameters.


    ls_job_parameters-name = 'IV_BUKRS'.
    ls_value-sign = 'I'.
    ls_value-option = 'EQ'.
    ls_value-low = iv_bukrs.
    APPEND ls_value TO ls_job_parameters-t_value.

    APPEND ls_job_parameters TO lt_job_parameters.
    CLEAR ls_job_parameters.


    ls_job_parameters-name = 'IV_GJAHR'.
    ls_value-sign = 'I'.
    ls_value-option = 'EQ'.
    ls_value-low = iv_gjahr.
    APPEND ls_value TO ls_job_parameters-t_value.

    APPEND ls_job_parameters TO lt_job_parameters.
    CLEAR ls_job_parameters.

    ls_job_parameters-name = 'IV_MONAT'.
    ls_value-sign = 'I'.
    ls_value-option = 'EQ'.
    ls_value-low = iv_monat.
    APPEND ls_value TO ls_job_parameters-t_value.

    APPEND ls_job_parameters TO lt_job_parameters.
    CLEAR ls_job_parameters.


    TRY.

        cl_apj_rt_api=>schedule_job(
          EXPORTING
            iv_job_template_name   = lv_template_name
            iv_job_text            = lv_job_text
            is_start_info          = ls_start_info
            is_scheduling_info     = ls_scheduling_info
            is_end_info            = ls_end_info
            it_job_parameter_value = lt_job_parameters
          IMPORTING
            ev_jobname             = lv_jobname
            ev_jobcount            = lv_jobcount
        ).


        cl_apj_rt_api=>get_job_status(
          EXPORTING
            iv_jobname         = lv_jobname
            iv_jobcount        = lv_jobcount
          IMPORTING
            ev_job_status      = lv_status
            ev_job_status_text = lv_statustext
        ).


      CATCH cx_apj_rt INTO DATA(exc).
        lv_txt = exc->get_longtext( ).
        ls_ret = exc->get_bapiret2( ).

        UPDATE zsoa_elt_0001 SET status = '1' WHERE run_uuid = @iv_run_uuid.
    ENDTRY.


  ENDMETHOD.
  METHOD add_to_buffer.
    INSERT VALUE #( flag = iv_flag lv_data = is_employee ) INTO TABLE mt_buffer.
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



CLASS lhc_elc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR elc RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR elc RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE elc.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE elc.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE elc.

    METHODS read FOR READ
      IMPORTING keys FOR READ elc RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK elc.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR elc RESULT result.

    METHODS scanc FOR MODIFY
      IMPORTING keys FOR ACTION elc~scanc.

    METHODS ssave FOR MODIFY
      IMPORTING keys FOR ACTION elc~ssave.
    METHODS setbuttonact FOR MODIFY
      IMPORTING keys FOR ACTION elc~setbuttonact RESULT result.

ENDCLASS.

CLASS lhc_elc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA(lv_dup) = abap_false.
    DATA(lv_backmonat) = abap_false.
    DATA(lv_flag) = abap_false.
    DATA: l_gjahr TYPE numc4,
          l_date  TYPE datum.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity1>).

      IF <ls_entity1>-bukrs IS INITIAL.

        APPEND VALUE #(
          %cid = <ls_entity1>-%cid
        ) TO failed-elc.

        APPEND VALUE #(
          %cid = <ls_entity1>-%cid
          %msg = new_message(
                    id       = 'ZEL_MSG'
                    number   = '002'
                    severity = if_abap_behv_message=>severity-error
                  )
        ) TO reported-elc.

        CONTINUE.
      ENDIF.

      IF <ls_entity1>-gjahr IS INITIAL.


        APPEND VALUE #(
              %cid = <ls_entity1>-%cid
            ) TO failed-elc.

        APPEND VALUE #(
          %cid = <ls_entity1>-%cid
          %msg = new_message(
                    id       = 'ZEL_MSG'
                    number   = '003'
                    severity = if_abap_behv_message=>severity-error
                  )
        ) TO reported-elc.

        CONTINUE.

      ENDIF.

      IF <ls_entity1>-monat IS INITIAL.
        APPEND VALUE #(
             %cid = <ls_entity1>-%cid
           ) TO failed-elc.

        APPEND VALUE #(
          %cid = <ls_entity1>-%cid
          %msg = new_message(
                    id       = 'ZEL_MSG'
                    number   = '004'
                    severity = if_abap_behv_message=>severity-error
                  )
        ) TO reported-elc.

        CONTINUE.
      ENDIF.



      SELECT    bukrs,run_uuid AS runuuid,monat,gjahr,rldnr
            FROM zsoa_elt_0001
             WHERE bukrs = @<ls_entity1>-bukrs
                    AND monat = @<ls_entity1>-monat
                    AND gjahr = @<ls_entity1>-gjahr
                   AND  run_uuid <> @<ls_entity1>-runuuid
                   INTO TABLE @DATA(lt_elc).
      IF sy-subrc IS INITIAL.
        APPEND VALUE #(
            %cid = <ls_entity1>-%cid
          ) TO failed-elc.

        APPEND VALUE #(
          %cid = <ls_entity1>-%cid
          %msg = new_message(
                    id       = 'ZEL_MSG'
                    number   = '001'
                    severity = if_abap_behv_message=>severity-error
                  )
        ) TO reported-elc.

        CONTINUE.
      ENDIF.

      l_gjahr = <ls_entity1>-gjahr - 1.
      l_date  = <ls_entity1>-gjahr && <ls_entity1>-monat && '01'.
      l_date  = l_date - 1.
      IF l_date(4) NE <ls_entity1>-gjahr.
        SELECT COUNT(*) FROM zsoa_elt_0001
           WHERE gjahr EQ @<ls_entity1>-gjahr
             AND bukrs EQ @<ls_entity1>-bukrs.

        IF sy-subrc EQ 0.
          SELECT COUNT(*) FROM zsoa_elt_0001
             WHERE gjahr EQ @l_date(4)
               AND monat EQ @l_date+4(2)
               AND bukrs EQ @<ls_entity1>-bukrs.

          IF sy-subrc NE 0.
            APPEND VALUE #(
         %cid = <ls_entity1>-%cid
       ) TO failed-elc.

            APPEND VALUE #(
              %cid = <ls_entity1>-%cid
              %msg = new_message(
                        id       = 'ZEL_MSG'
                        number   = '005'
                        severity = if_abap_behv_message=>severity-error
                      )
            ) TO reported-elc.

            CONTINUE.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT COUNT(*) FROM zsoa_elt_0001
         WHERE gjahr EQ @l_date(4)
           AND monat EQ @l_date+4(2)
           AND bukrs EQ @<ls_entity1>-bukrs.
        IF sy-subrc NE 0.
          APPEND VALUE #(
              %cid = <ls_entity1>-%cid
            ) TO failed-elc.

          APPEND VALUE #(
            %cid = <ls_entity1>-%cid
            %msg = new_message(
                      id       = 'ZEL_MSG'
                      number   = '005'
                      severity = if_abap_behv_message=>severity-error
                    )
          ) TO reported-elc.

          CONTINUE.
        ENDIF.
      ENDIF.

    ENDLOOP.









    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).


      DATA ls_data TYPE zsoa_elt_0001.   " <-- kendi tablo/structure tipini yaz

      " Map entity fields to structure
      ls_data-run_uuid       = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).

      ls_data-bukrs          = <ls_entity>-bukrs.
      ls_data-gjahr          = <ls_entity>-gjahr.
      ls_data-rldnr          = '0L'.
      ls_data-monat          = <ls_entity>-monat.
      ls_data-monattext      = <ls_entity>-monattext.
      ls_data-printaltacc    = <ls_entity>-printaltacc.
      ls_data-status         = '1'.
      ls_data-firstymno      = <ls_entity>-firstymno.
      ls_data-lastymno       = <ls_entity>-lastymno.
      ls_data-toplamalacak   = <ls_entity>-toplamalacak.
      ls_data-toplamborc     = <ls_entity>-toplamborc.
      ls_data-toplam         = <ls_entity>-toplam.
      ls_data-topsatirsayi   = <ls_entity>-topsatirsayi.
      ls_data-waers          = <ls_entity>-waers.
      ls_data-createdby      = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD DATA(ls_ts1).
      ls_data-createdat      = ls_ts1.
      ls_data-local_last_changed_by = <ls_entity>-localchangedby.
      ls_data-local_last_changed_at = <ls_entity>-localchangedat.
      ls_data-last_changed_at  = <ls_entity>-lastchangedat.

      " Add to buffer as create
      lo_buffer->add_to_buffer(
        iv_flag = 'C'
        is_employee = ls_data )." <-- method parametrenin adı neyse onu yaz

* INSERT VALUE #( %cid = <ls_entity>-%cid empID = ls_employee-emp_id ) INTO TABLE mapped-elc.
      " Return mapped keys (RAP için zorunlu)
      INSERT VALUE #(
          %cid    = <ls_entity>-%cid
          runuuid =  ls_data-run_uuid   " Eğer RunUuid key ise
        )
        INTO TABLE mapped-elc.   " <-- entity adını yaz

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      " Fetch existing employee from DB to buffer with flag U
      DATA ls_db TYPE zsoa_elt_0001.
*      SELECT SINGLE * FROM zun_emp_tab WHERE emp_id = @<ls_entity>-EmpId INTO _db.
*      " Overwrite fields if updated in <ls_entity>
*      IF <ls_entity>-FirstName IS NOT INITIAL.
*        ls_db-first_name = <ls_entity>-FirstName.
*      ENDIF.
*      IF <ls_entity>-LastName IS NOT INITIAL.
*        ls_db-last_name = <ls_entity>-LastName.
*      ENDIF.
*      IF <ls_entity>-DateOfBirth IS NOT INITIAL.
*        ls_db-date_of_birth = <ls_entity>-DateOfBirth.
*      ENDIF.
*      IF <ls_entity>-email IS NOT INITIAL.
*        ls_db-email = <ls_entity>-email.
*      ENDIF.
*      IF <ls_entity>-HireDate IS NOT INITIAL.
*        ls_db-hire_date = <ls_entity>-HireDate.
*      ENDIF.
*      IF <ls_entity>-salary IS NOT INITIAL.
*        ls_db-salary = <ls_entity>-salary.
*      ENDIF.
*      IF <ls_entity>-curry IS NOT INITIAL.
*        ls_db-curry = <ls_entity>-curry.
*      ENDIF.


      GET TIME STAMP FIELD DATA(ls_ts1).

      ls_db-local_last_changed_by  = cl_abap_context_info=>get_user_alias( ).
      ls_db-local_last_changed_at      = ls_ts1.
      " Add updated employee to buffer with flag 'U'
      lo_buffer->add_to_buffer( iv_flag = 'U' is_employee = ls_db ).

      " Return mapped keys
      INSERT VALUE #( %cid = <ls_entity>-%cid_ref  runuuid = ls_db-run_uuid ) INTO TABLE mapped-elc.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      " Create minimal structure for deletion
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
        INTO @DATA(lv_status).
      IF sy-subrc IS INITIAL.

        " Silmeyi engelle
        APPEND VALUE #(
          %tky = <ls_key>-%tky
        ) TO failed-elc.

        " Mesaj dön
        APPEND VALUE #(
          %tky = <ls_key>-%tky
          %msg = new_message(
                   id       = 'ZEL_MSG'
                   number   = '006'
                   severity = if_abap_behv_message=>severity-error
                 )
        ) TO reported-elc.

        CONTINUE.
      ENDIF.

      DATA ls_employee TYPE zsoa_elt_0001.
      ls_employee-run_uuid = <ls_key>-runuuid.

      " Add to buffer with flag 'D'
      lo_buffer->add_to_buffer( iv_flag = 'D' is_employee = ls_employee ).

      " Return mapped keys
      INSERT VALUE #( %cid = <ls_key>-%cid_ref runuuid = <ls_key>-runuuid ) INTO TABLE mapped-elc.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    SELECT  run_uuid     AS runuuid,

  bukrs               ,
  gjahr                ,
  rldnr                 ,
  monat,
status
 FROM zsoa_elt_0001
 FOR ALL ENTRIES IN @keys
 WHERE  run_uuid    =  @keys-runuuid
   INTO TABLE @DATA(lt_mult).

    result = CORRESPONDING #( lt_mult ).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features .


    READ ENTITIES OF zi_soa_el_0001 IN LOCAL MODE
         ENTITY elc
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT DATA(elcdata)
         FAILED failed.
    result = VALUE #(
      FOR activity IN elcdata
      (
        runuuid = activity-runuuid
        %tky    = activity-%tky   "KRİTİK
       %update = if_abap_behv=>fc-o-disabled
*COND #(
*
**          WHEN activity-status = '2' OR activity-status = '3'
**            THEN if_abap_behv=>fc-o-disabled
**          ELSE if_abap_behv=>fc-o-enabled
*        )
       %delete = COND #(
          WHEN activity-status = '2' OR activity-status = '3'
            THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled
        )
        " Action enable/disable
        %action-scanc = COND #(
          WHEN activity-status EQ '3'
            THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled
        )

        %action-ssave = COND #(
          WHEN activity-status <> '1'
            THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled
        )


      )
    ).





  ENDMETHOD.

  METHOD scanc.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

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
               AND ( status = '2' OR status = '3' )
        INTO @DATA(lv_status).
      IF sy-subrc IS INITIAL.

        " Silmeyi engelle
        APPEND VALUE #(
          %tky = <ls_key>-%tky
        ) TO failed-elc.

        " Mesaj dön
        APPEND VALUE #(
          %tky = <ls_key>-%tky
          %msg = new_message(
                   id       = 'ZEL_MSG'
                   number   = '007'
                   severity = if_abap_behv_message=>severity-error
                 )
        ) TO reported-elc.

        CONTINUE.
      ENDIF.


      DATA ls_employee TYPE zsoa_elt_0001.
      ls_employee-run_uuid = <ls_key>-runuuid.
*       ls_employee-gjahr = <ls_key>-.
      lo_buffer->add_to_buffer( iv_flag = 'SCANC' is_employee = ls_employee ).
    ENDLOOP.
  ENDMETHOD.

  METHOD ssave.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      SELECT SINGLE *
   FROM zsoa_elt_0001
   WHERE run_uuid EQ @<ls_key>-runuuid
    INTO @DATA(ls_t01).
      IF sy-subrc IS INITIAL.
        " 1️⃣ DB'den mevcut kaydı oku
        SELECT SINGLE status
          FROM zsoa_elt_0001
         WHERE bukrs = @ls_t01-bukrs
                 AND monat < @ls_t01-monat
                 AND gjahr = @ls_t01-gjahr
                 AND  status = '1'
          INTO @DATA(lv_status).
        IF sy-subrc IS INITIAL.

          " Silmeyi engelle
          APPEND VALUE #(
            %tky = <ls_key>-%tky
          ) TO failed-elc.

          " Mesaj dön
          APPEND VALUE #(
            %tky = <ls_key>-%tky
            %msg = new_message(
                     id       = 'ZEL_MSG'
                     number   = '008'
                     severity = if_abap_behv_message=>severity-error
                   )
          ) TO reported-elc.

          CONTINUE.
        ENDIF.
        IF ls_t01-monat EQ '01' AND ls_t01-gjahr EQ '2025'.
        ELSE.
          DATA(lv_prev_monat) = ls_t01-monat.
          DATA(lv_prev_gjahr) = ls_t01-gjahr.

          IF lv_prev_monat = '01'.
            lv_prev_monat = '12'.
            lv_prev_gjahr = lv_prev_gjahr - 1.
          ELSE.
            lv_prev_monat = lv_prev_monat - 1.
          ENDIF.

          SELECT SINGLE * FROM zsoa_elt_0004
            WHERE bukrs = @ls_t01-bukrs
              AND gjahr = @lv_prev_gjahr
              AND monat = @lv_prev_monat
            INTO @DATA(ls_prev).
          IF sy-subrc <> 0.

            " kayıt yok → hata ver
            APPEND VALUE #(
              %tky = <ls_key>-%tky
            ) TO failed-elc.

            APPEND VALUE #(
              %tky = <ls_key>-%tky
              %msg = new_message(
                       id       = 'ZEL_MSG'
                       number   = '009'
                       severity = if_abap_behv_message=>severity-error
                     )
            ) TO reported-elc.

            CONTINUE.

          ENDIF.

        ENDIF.
      ENDIF.


      DATA ls_employee TYPE zsoa_elt_0001.
      ls_employee-run_uuid = <ls_key>-runuuid.
*       ls_employee-gjahr = <ls_key>-.
      lo_buffer->add_to_buffer( iv_flag = 'SSAVE' is_employee = ls_employee ).
    ENDLOOP.

  ENDMETHOD.

  METHOD setbuttonact.




  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_soa_el_0001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_soa_el_0001 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.

    DATA(lt_acct) = mapped-elc.
    IF lt_acct IS NOT INITIAL.
      LOOP AT mapped-elc REFERENCE INTO DATA(lr_elc).
        lr_elc->runuuid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      ENDLOOP.
    ENDIF.


  ENDMETHOD.

  METHOD save.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT lo_buffer->mt_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).
      CASE <ls_buf>-flag.
        WHEN 'C'.  " If the flag is 'C', perform Insert operation
          INSERT zsoa_elt_0001 FROM @<ls_buf>-lv_data.
        WHEN 'U'.  " If the flag is 'U', perform Update operation
          UPDATE zsoa_elt_0001 FROM @<ls_buf>-lv_data.
        WHEN 'D'.  " If the flag is 'D', perform Delete operation
          SELECT SINGLE * FROM zsoa_elt_0001 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid INTO @DATA(ls_d1).
          IF sy-subrc IS INITIAL AND ls_d1-status NE '1'.
            DELETE FROM zsoa_elt_0004 WHERE bukrs = @ls_d1-bukrs AND gjahr = @ls_d1-gjahr AND monat = @ls_d1-gjahr.
          ENDIF.
          DELETE FROM zsoa_elt_0001 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
        WHEN 'SSAVE'.
          UPDATE zsoa_elt_0001 SET status = '2' WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.

          SELECT SINGLE * FROM zsoa_elt_0001 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid INTO @DATA(ls_d).
          lo_buffer->job_data_create(
            iv_run_uuid = ls_d-run_uuid
            iv_bukrs    = ls_d-bukrs
            iv_gjahr    = ls_d-gjahr
            iv_rldnr    = ls_d-rldnr
            iv_monat    = ls_d-monat
          ).

        WHEN 'SCANC'.
          UPDATE zsoa_elt_0001 SET status = '1' WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
          DELETE FROM zsoa_elt_0002 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid.
          SELECT SINGLE * FROM zsoa_elt_0001 WHERE run_uuid = @<ls_buf>-lv_data-run_uuid INTO @DATA(ls_d2).
          IF sy-subrc IS INITIAL.
            DELETE FROM zsoa_elt_0004 WHERE bukrs = @ls_d2-bukrs AND gjahr = @ls_d2-gjahr AND monat = @ls_d2-monat.
          ENDIF.
      ENDCASE.
    ENDLOOP.
    CLEAR lo_buffer->mt_buffer.  " Clear the buffer after saving changes
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
