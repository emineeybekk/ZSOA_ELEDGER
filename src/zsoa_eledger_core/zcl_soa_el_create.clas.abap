CLASS zcl_soa_el_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .



  PUBLIC SECTION.

    DATA: gt_edefter  TYPE TABLE OF  zsoa_els_0001,
          gt_doc_head TYPE TABLE OF zsoa_els_fagl_head,
          gt_h_mtn    TYPE TABLE OF zsoa_elt_0006,
*          gt_b_tip TYPE TABLE OF zsoa_elt_0007,
          gt_o_tip    TYPE TABLE OF zsoa_elt_0008.

    TYPES: BEGIN OF ty_belnr,
             belnr TYPE belnr_d,
             budat TYPE budat,
           END OF ty_belnr.
    DATA: gt_belnr TYPE TABLE OF ty_belnr.
    DATA : BEGIN OF gs_key,
             run_uuid TYPE sysuuid_x16,
             bukrs    TYPE bukrs,
             gjahr    TYPE gjahr,
             rldnr    TYPE fins_ledger,
             monat    TYPE monat,
           END OF gs_key.

    DATA: gt_gjahr TYPE RANGE OF gjahr
     .
    METHODS constructor
      IMPORTING iv_run_uuid TYPE sysuuid_x16 OPTIONAL
                iv_bukrs    TYPE bukrs OPTIONAL
                iv_gjahr    TYPE gjahr OPTIONAL
                iv_rldnr    TYPE fins_ledger OPTIONAL
                iv_monat    TYPE monat OPTIONAL.
    METHODS call_for_data RETURNING VALUE(rt_err) TYPE bapirettab.
    CLASS-METHODS get_instance
      IMPORTING iv_run_uuid TYPE sysuuid_x16 OPTIONAL
                iv_bukrs    TYPE bukrs OPTIONAL
                iv_gjahr    TYPE gjahr OPTIONAL
                iv_rldnr    TYPE fins_ledger OPTIONAL
                iv_monat    TYPE monat OPTIONAL

      EXPORTING r_instance  TYPE REF TO zcl_soa_el_create.
    METHODS csv_down.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA : instance     TYPE REF TO zcl_soa_el_create.
    METHODS refresh_all.
    METHODS read_accountingdocumentjournal.
    METHODS get_cust_data.
    METHODS prepare_e_defter_data.
    METHODS delete_tab01.



ENDCLASS.



CLASS ZCL_SOA_EL_CREATE IMPLEMENTATION.


  METHOD constructor.
    CLEAR: gs_key.
    gs_key-run_uuid = iv_run_uuid.
    gs_key-bukrs       = iv_bukrs .
    gs_key-gjahr       = iv_gjahr.
    gs_key-rldnr       = iv_rldnr.
    gs_key-monat  = iv_monat.

  ENDMETHOD.


  METHOD get_instance.
    IF instance IS NOT BOUND.

      instance = NEW #( iv_run_uuid = iv_run_uuid
                        iv_bukrs = iv_bukrs
                        iv_gjahr = iv_gjahr
                        iv_rldnr = iv_rldnr
                        iv_monat = iv_monat ).

    ENDIF.
    r_instance = instance.
  ENDMETHOD.


  METHOD call_for_data.
    refresh_all( ).
    get_cust_data(  ).
    read_accountingdocumentjournal( ).
    prepare_e_defter_data( ).
  ENDMETHOD.


  METHOD get_cust_data.

    SELECT *
      FROM  zsoa_elt_0006
      WHERE hkont NE @space
      INTO TABLE @gt_h_mtn.
* SELECT *
*   FROM  zsoa_elt_0007
*   WHERE blart NE @space
*   INTO TABLE @gt_b_tip .
    SELECT *
      FROM zsoa_elt_0008
      WHERE blart NE @space
      INTO TABLE @gt_o_tip .


  ENDMETHOD.


  METHOD prepare_e_defter_data.

    CLEAR:gt_edefter[], gt_edefter, gt_edefter.


  ENDMETHOD.


  METHOD read_accountingdocumentjournal.
    DATA: gv_maddeno   TYPE zsoa_elt_0004-madde_no,
          gv_buzei     TYPE  zsoa_elt_0004-madde_no,
          gv_item      TYPE zsoa_elde_0011,
          lv_lines     TYPE i,
          lv_createdby TYPE abp_creation_user,
          lv_waers     TYPE waers,
          lv_dmbtr     TYPE  dmbtr.


    CLEAR:gt_belnr.
    SELECT aj~accountingdoccreatedbyuser AS uname ,
            aj~fiscalperiod AS monat,
           aj~postingdate AS budat,
           aj~accountingdocument AS belnr ,
           aj~accountingdocumentheadertext  AS ktxt ,
*           aj~debitamountincocodecrcy AS dmbtr_s ,
*           aj~creditamountincocodecrcy AS dmbtr_h ,
*        madde_no,
           aj~accountingdocumenttype AS blart,
*        *madde_no2,
           aj~glaccount AS hkont ,
           aj~glaccountname AS atext ,
          aj~debitamountincocodecrcy AS dmbtr_dec,
          aj~debitcreditcode AS shkzg ,
          aj~documentdate AS budat2,
          z7~btype,
          z7~btext,
          aj~documentreferenceid AS xblnr,
          aj~accountingdocument AS belnr2,
          aj~documentdate AS bldat ,
          z8~otype,
          aj~documentitemtext AS sgtxt,
          aj~companycodecurrency AS waers ,
*       kayitno ,
*         aj~debitamountincocodecrcy AS dmbtr,
          CASE
          WHEN  aj~debitcreditcode = 'S' THEN debitamountincocodecrcy
          WHEN aj~debitcreditcode = 'H' THEN creditamountincocodecrcy
           END AS dmbtr,
         aj~companycode AS bukrs ,
         aj~fiscalyear AS gjahr,
         aj~accountingdocumentheadertext  AS  bktxt,
         aj~ledgergllineitem AS buzei,
         aj~debitamountincocodecrcy,
         aj~creditamountincocodecrcy
    FROM i_accountingdocumentjournal AS aj
    LEFT OUTER JOIN zsoa_elt_0007 AS z7 ON z7~blart = aj~accountingdocumenttype
    LEFT OUTER JOIN zsoa_elt_0008 AS z8 ON z8~blart = aj~accountingdocumenttype
    WHERE aj~fiscalperiod EQ @gs_key-monat
      AND aj~companycode EQ @gs_key-bukrs
      AND aj~fiscalyear EQ @gs_key-gjahr
      AND aj~ledger EQ @gs_key-rldnr
       AND ( aj~accountingdocumentcategory EQ @space OR aj~accountingdocumentcategory EQ 'U'
             OR aj~accountingdocumentcategory EQ 'A' OR aj~accountingdocumentcategory EQ 'B'
             OR aj~accountingdocumentcategory EQ 'J' )

    INTO CORRESPONDING FIELDS OF TABLE @gt_edefter.
    IF sy-subrc IS INITIAL.

      SELECT SINGLE MAX( madde_no ) FROM zsoa_elt_0004
              WHERE bukrs EQ @gs_key-bukrs
                AND gjahr EQ @gs_key-gjahr
                INTO @gv_maddeno.
      SELECT SINGLE MAX( buzei ) FROM zsoa_elt_0004
            WHERE bukrs EQ @gs_key-bukrs
                AND gjahr EQ @gs_key-gjahr
                 INTO @gv_buzei.
      DATA: lt_edefter TYPE TABLE OF zsoa_els_0001.
      lt_edefter[] = gt_edefter[].
      SORT gt_edefter BY bukrs gjahr monat budat belnr buzei.
      DATA: lv_v TYPE char10.
      LOOP AT gt_edefter ASSIGNING FIELD-SYMBOL(<fs_data>).
        ADD 1 TO gv_buzei.
        ADD 1 TO gv_item.
        CONDENSE:  gv_buzei, gv_item .
        <fs_data>-buzei =  gv_buzei .
        <fs_data>-dmbtr_s  =
                 REDUCE dmbtr( INIT val TYPE dmbtr
                    FOR wa IN lt_edefter
                  WHERE ( belnr = <fs_data>-belnr  AND
                          bukrs = <fs_data>-bukrs AND
                          shkzg = 'S' AND
                          gjahr = <fs_data>-gjahr )
                   NEXT val = val + wa-debitamountincocodecrcy ).
        <fs_data>-dmbtr_h  =
                 REDUCE dmbtr( INIT val TYPE dmbtr
                    FOR wa IN lt_edefter
                  WHERE ( belnr = <fs_data>-belnr  AND
                          bukrs = <fs_data>-bukrs AND
                          shkzg = 'H' AND
                          gjahr = <fs_data>-gjahr )
                   NEXT val = val + wa-creditamountincocodecrcy ).
        <fs_data>-dmbtr_h  = <fs_data>-dmbtr_h * -1.
        IF <fs_data>-shkzg EQ 'H'.
          <fs_data>-dmbtr  = <fs_data>-dmbtr * -1.
        ENDIF.
        <fs_data>-item    = gv_item.
        CONDENSE:  <fs_data>-buzei, <fs_data>-item .
*        <fs_data>-run_uuid =  to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).

        <fs_data>-run_uuid = gs_key-run_uuid.
        lv_v = |{ <fs_data>-hkont ALPHA = OUT }|.
        CONDENSE lv_v .
        <fs_data>-hkont2 = lv_v+0(3).
        <fs_data>-htext =  VALUE #( gt_h_mtn[ hkont = <fs_data>-hkont2 ]-text OPTIONAL ).
        ""SOA 'YA ÖZEL KOD TR DE AÇILACAK
*        <fs_data>-hkont2 = <fs_data>-hkont+0(3).
*        <fs_data>-htext =  VALUE #( gt_h_mtn[ hkont = <fs_data>-hkont2 ]-text OPTIONAL ).
*END
        CONCATENATE <fs_data>-hkont+0(3) <fs_data>-hkont+3(3)
                     <fs_data>-hkont+6(2) <fs_data>-hkont+8(2)
                     INTO <fs_data>-akont SEPARATED BY '.'.

        IF <fs_data>-btype IS NOT INITIAL.
          IF <fs_data>-xblnr IS INITIAL .
            <fs_data>-xblnr = <fs_data>-belnr.
          ENDIF.
        ELSE.

          <fs_data>-xblnr = ''.
          <fs_data>-bldat = ''.
        ENDIF.
        IF <fs_data>-sgtxt IS INITIAL.

          <fs_data>-sgtxt = <fs_data>-btext.

        ELSE.
          <fs_data>-sgtxt   = <fs_data>-sgtxt  .
        ENDIF.
      ENDLOOP.


    ENDIF.
*    SORT  gt_edefter  BY belnr.
    DATA: lt_log  TYPE TABLE OF zsoa_elt_0002,
          ls_mlog TYPE  zsoa_elt_0004,
          ls_blog TYPE  zsoa_elt_0001,
          lt_mlog TYPE TABLE OF zsoa_elt_0004.
    LOOP AT gt_edefter INTO DATA(ls_ed) GROUP BY ( belnr = ls_ed-belnr ).
      ADD 1 TO gv_maddeno.
      LOOP AT gt_edefter ASSIGNING <fs_data> WHERE  belnr = ls_ed-belnr.
        lv_waers = <fs_data>-waers.
        SHIFT gv_maddeno LEFT DELETING LEADING '0'.
        <fs_data>-madde_no = gv_maddeno.
        CONDENSE:   <fs_data>-madde_no,gv_maddeno.
*        MOVE-CORRESPONDING <fs_data> TO ls_mlog.
*        ls_mlog-borc = <fs_data>-dmbtr_h.
*        ls_mlog-alacak = <fs_data>-dmbtr_s.

*        CLEAR: ls_mlog-madde_no, ls_mlog-buzei, ls_mlog-uname, ls_mlog-tarih.
*        COLLECT ls_mlog INTO lt_mlog.

      ENDLOOP.
      MOVE-CORRESPONDING <fs_data> TO ls_mlog.
      ls_mlog-borc = <fs_data>-dmbtr_h.
      ls_mlog-alacak = <fs_data>-dmbtr_s.
      CLEAR: ls_mlog-madde_no, ls_mlog-buzei, ls_mlog-uname, ls_mlog-tarih.
      COLLECT ls_mlog INTO lt_mlog.
    ENDLOOP.

    MOVE-CORRESPONDING gt_edefter TO lt_log.

    READ TABLE lt_mlog ASSIGNING FIELD-SYMBOL(<fs_mlog>) INDEX 1.
    IF sy-subrc IS INITIAL.
      <fs_mlog>-madde_no = gv_maddeno.
      <fs_mlog>-buzei = gv_buzei.
      <fs_mlog>-rldnr = '0L'.
      <fs_mlog>-tarih = sy-datum.
      <fs_mlog>-uname = sy-uname.

      CLEAR: lv_dmbtr,lv_lines,  lv_createdby.
      lv_createdby    = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD DATA(ls_ts1).
      lv_lines = lines( lt_log ).
      lv_dmbtr = <fs_mlog>-borc + <fs_mlog>-alacak.
      UPDATE zsoa_elt_0001 SET topsatirsayi = @lv_lines ,toplamborc = @<fs_mlog>-borc ,
      toplamalacak = @<fs_mlog>-alacak, toplam = @lv_dmbtr, local_last_changed_at = @ls_ts1,
      local_last_changed_by = @lv_createdby , waers = @lv_waers WHERE run_uuid EQ @gs_key-run_uuid.
    ENDIF.

*    MOVE-CORRESPONDING gt_edefter TO  lt_mlog .
    IF gt_edefter[] IS NOT INITIAL.

      MODIFY  zsoa_elt_0002 FROM TABLE @lt_log.
      COMMIT WORK.
      MODIFY zsoa_elt_0004 FROM TABLE @lt_mlog.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.


  METHOD refresh_all.
    CLEAR: gt_edefter ,
              gt_doc_head .
*              gt_bkpf    ,
*              gt_bseg     ,
*              gt_bsec   ,
*              gt_acdoca .
* CLEAR:gt_doc_head[],gt_doc_item[], gt_all_data[], gt_all_data.
  ENDMETHOD.


  METHOD delete_tab01.
    DELETE FROM  zsoa_elt_0001.
  ENDMETHOD.


  METHOD csv_down.


    SELECT    uname,
              budat,
              belnr,
              ktxt,
              dmbtr_s,
              dmbtr_h,
              madde_no,
              blart,
              buzei ,
              madde_no AS  madde_no3,
              hkont,
              htext,
              akont,
              atext,
              dmbtr,
              shkzg,
              budat AS budat1,
              btype,
              btext,
              xblnr,
              belnr AS belnr1,
              bldat,
              otype,
              sgtxt
       FROM zsoa_elt_0002
       WHERE gjahr EQ @gs_key-gjahr
         AND bukrs EQ @gs_key-bukrs
         AND monat EQ @gs_key-monat
                INTO TABLE @DATA(lt_test).
    SORT lt_test BY  madde_no.

    DATA(lv_xstring_v1) = cl_csv_factory=>new_writer(
                           )->set_delimiter( ';'
                           )->set_write_header( abap_false
                           )->write( REF #( lt_test ) ).
*"3- XSTRING → STRING
    " Excel için UTF8 BOM ekle
    DATA lv_bom  TYPE xstring VALUE 'EFBBBF'.
    DATA: lv_xstring_final  TYPE xstring,
          default_file_name TYPE string,
           lv_mindate  TYPE dats.
    lv_xstring_final = lv_bom && lv_xstring_v1.

    DATA: ls_file TYPE zsoa_elt_0005.
    ls_file-client      = sy-mandt.
    ls_file-run_uuid    = gs_key-run_uuid.
    ls_file-rldnr      = '0L'.
    ls_file-monat       = gs_key-monat.
    ls_file-gjahr       = gs_key-gjahr.
    ls_file-bukrs       = gs_key-bukrs.
    ls_file-mimetype    = 'text/csv'.
*    ls_file-filename    =  gs_key-gjahr && gs_key-bukrs && gs_key-monat  && '.csv'.


    lv_mindate  = gs_key-gjahr && gs_key-monat && '01'.


    DATA(date_w_first_day_of_month) = lv_mindate.

    " Ay ve yılı integer olarak al
    DATA lv_year  TYPE i.
    DATA lv_month  TYPE monat.


    lv_year  = CONV i( date_w_first_day_of_month(4) ).   " YYYY
    lv_month = CONV i( date_w_first_day_of_month+4(2) ).  " MM

    " Bir sonraki ayın ilk günü
    IF lv_month = 12.
      lv_month = 1.
      lv_year  = lv_year + 1.
    ELSE.
      lv_month = lv_month + 1.
    ENDIF.

    DATA date_w_first_day_next_month TYPE d.
    date_w_first_day_next_month =
        CONV d( |{ lv_year }{ lv_month WIDTH = 2 PAD = '0' }01| ).

    " Ayın son günü
    DATA date_w_last_day_of_month TYPE d.
    date_w_last_day_of_month = date_w_first_day_next_month - 1.

    SELECT SINGLE stcd2  FROM zsoa_elt_0009
            WHERE bukrs EQ @gs_key-bukrs
            INTO @DATA(lv_vkn).
    CONCATENATE lv_vkn '-0000-' lv_mindate '-'
              date_w_last_day_of_month  '.csv'
              INTO default_file_name.
    ls_file-filename  = default_file_name.
    ls_file-attachment  = lv_xstring_final.

    ls_file-local_created_by  = cl_abap_context_info=>get_user_alias( ).
    GET TIME STAMP FIELD DATA(ls_ts1).
    ls_file-local_created_at    = ls_ts1.

    MODIFY zsoa_elt_0005 FROM @ls_file.

  ENDMETHOD.
ENDCLASS.
