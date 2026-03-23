CLASS zcl_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.
*data: lv_min type char10,
*      lv_mindate type dats,
*      lv_monatadd type monat,
*      lv_max type char10.
**     lv_min  = '01' && gs_key-monat && gs_key-gjahr.
*     lv_mindate  = '20260205'.
*
*
*" Ayın ilk günü
*DATA(date_w_first_day_of_month) = lv_mindate.
*
*" Ay ve yılı integer olarak al
*DATA lv_year  TYPE i.
*DATA lv_month  TYPE monat.
*
*
*lv_year  = CONV i( date_w_first_day_of_month(4) ).   " YYYY
*lv_month = CONV i( date_w_first_day_of_month+4(2) ).  " MM
*
*" Bir sonraki ayın ilk günü
*IF lv_month = 12.
*  lv_month = 1.
*  lv_year  = lv_year + 1.
*ELSE.
*  lv_month = lv_month + 1.
*ENDIF.
*
*DATA date_w_first_day_next_month TYPE d.
*date_w_first_day_next_month =
*    CONV d( |{ lv_year }{ lv_month WIDTH = 2 PAD = '0' }01| ).
*
*" Ayın son günü
*DATA date_w_last_day_of_month TYPE d.
*date_w_last_day_of_month = date_w_first_day_next_month - 1.
*
*         lv_mindate  = '20251205'.
** seleCT sINGLE *
* fROM I_PRODUCTIONROUTINGTP_2
* into @dATA(ls_d).
* DELETE FROM zsoa_elt_0002 wHERE  monat    =  '03' .
*  DELETE FROM zsoa_elt_0002 wHERE  monat    =  '01' .
*delete fROM zsoa_elt_0004 wHERE  monat    =  '03' .
*delete fROM zsoa_elt_0004 .
*delete fROM zsoa_elt_0001.
*delete fROM zsoa_elt_0002.
****wHERE   bukrs    = '3610'
***   and gjahr    = '2025'
****    and rldnr    = '0L'
***    and monat    =  '11' .
*zcl_soa_el_create=>get_instance(
*  EXPORTING
*    iv_run_uuid = '2312'
*    iv_bukrs    = '3610'
*   iv_gjahr    = '2025'
*    iv_rldnr    = '0L'
*    iv_monat    =  '01'
*  IMPORTING
*    r_instance  = DATA(ro_instance)
*).
*ro_instance->call_for_data(
*  RECEIVING
*    rt_err =  data(lv_e)
*).
***
*ro_instance->csv_down( ).

*data: ls_ot tYPE zsoa_elt_0008.
*ls_ot-blart = 'DZ'.
*ls_ot-otype = 'Banka'.
*
*modIFY zsoa_elt_0008 fROM @ls_ot.
*
*ls_ot-blart = 'KZ'.
*ls_ot-otype = 'Banka'.
*
*modIFY zsoa_elt_0008 fROM @ls_ot.
*
**
**
*
*
*data: ls_o6 tYPE zsoa_elt_0006.
*ls_o6-hkont = '211'.
*ls_o6-text = 'SATICILAR'.
*
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '610'.
*ls_o6-text = 'PAZARLAMA, SATIŞ VE DAĞITIM GİDERLERİ'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '216'.
*ls_o6-text = 'ÖDENECEK GELİR VERGİLERİ'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '126'.
*ls_o6-text = 'İNDİRİLECEK KATMA DEĞER VERGİSİ HESABI'.
*
*modIFY zsoa_elt_0006 fROM @ls_o6.
*ls_o6-hkont = '651'.
*ls_o6-text = 'PAZARLAMA, SATIŞ VE DAĞITIM GİDERLERİ'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*ls_o6-hkont = '121'.
*ls_o6-text = 'ALICILAR'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '440'.
*ls_o6-text = ' SATIŞTAN İADELER (-)'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*
*ls_o6-hkont = '419'.
*ls_o6-text = 'YURTİÇİ SATIŞAR'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '410'.
*ls_o6-text = 'YURTDIŞI SATIŞLAR'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '650'.
*ls_o6-text = 'GENEL YÖNETİM GİDERLERİ'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*ls_o6-hkont = '220'.
*ls_o6-text = 'HESAPLANAN KATMA DEĞER VERGİSİ'.
*modIFY zsoa_elt_0006 fROM @ls_o6.
*
*
*


**  DELETE FROM zsoa_elt_0004.

*seLECT *
*fROM ztest_el
*into tABLE @dATA(lt_s).
*****
*
**
*
*data: ls_i tYPE zsoa_elt_0007.
*ls_i-blart = 'SA'.
*ls_i-btype = 'other'.
*ls_i-btext = 'ana hesap kaydı'.
*moDIFY zsoa_elt_0007 fROM @ls_i.
**
*ls_i-blart = 'DR'.
*ls_i-btype = 'invoice'.
*ls_i-btext = 'Müşteri Faturası'.
*moDIFY zsoa_elt_0007 fROM @ls_i.
*ls_i-blart = 'DG'.
*ls_i-btype = 'invoice'.
*ls_i-btext = 'Müşteri Faturası'.
*moDIFY zsoa_elt_0007 fROM @ls_i.



*data: ls_i tYPE zmmt_inter_type.
*ls_i-interruptiontype = 'a1'.
*ls_i-interruptiontypetxt = 'test1'.
*
*moDIFY zmmt_inter_type fROM @ls_i.
*ls_i-interruptiontype = 'a2'.
*ls_i-interruptiontypetxt = 'test2'.
*
*moDIFY zmmt_inter_type fROM @ls_i.
*    ENDIF.
delete fROM zsoa_elt_0001.
delete fROM zsoa_elt_0002.
 DATA: ls_data TYPE zsoa_elt_0002.

ls_data-run_uuid  = cl_system_uuid=>create_uuid_x16_static( ).
ls_data-item      = '1'.
ls_data-monat     = '01'.
ls_data-uname     = sy-uname.
ls_data-budat     = sy-datum.
ls_data-belnr     = '1000000001'.
ls_data-ktxt      = 'Test Kaydı'.

ls_data-dmbtr_s   = '1000.00'.
ls_data-dmbtr_h   = '0.00'.
ls_data-madde_no  = '0001'.
ls_data-blart     = 'SA'.
ls_data-buzei     = '001'.
ls_data-madde_no2 = '0001'.
ls_data-hkont     = '120000'.
ls_data-htext     = 'Alıcılar'.
ls_data-akont     = '120001'.
ls_data-atext     = 'Yurtiçi Alıcılar'.
ls_data-dmbtr_dec = '1000.00'.
ls_data-shkzg     = 'S'.
ls_data-budat2    = sy-datum.
ls_data-btype     = '01'.
ls_data-btext     = 'Muhasebe Belgesi'.
ls_data-xblnr     = 'REF001'.
ls_data-belnr2    = '2000000001'.
ls_data-bldat     = sy-datum.
ls_data-otype     = 'N'.
ls_data-sgtxt     = 'Satır Açıklaması'.
ls_data-waers     = 'TRY'.
ls_data-kayitno   = 'K001'.
ls_data-dmbtr     = '1000.00'.
ls_data-buzei2    = '001'.
ls_data-xref2_hd  = 'HDR001'.
ls_data-bukrs     = '1000'.
ls_data-gjahr     = '2025'.
ls_data-bktxt     = 'Belge Başlık Açıklaması'.

INSERT zsoa_elt_0002 FROM @ls_data.
**
DATA: ls_k TYPE zsoa_elt_0001.

ls_k-run_uuid     = ls_data-run_uuid.

ls_k-bukrs         = '1000'.
ls_k-gjahr         = '2025'.
ls_k-rldnr         = '0L'.
ls_k-monat         = '01'.
ls_k-printaltacc   = abap_true.
ls_k-status        = '2'.
ls_k-firstymno     = '0000000001'.
ls_k-lastymno      = '0000000100'.

ls_k-toplamalacak  = '150000.00'.
ls_k-toplamborc    = '120000.00'.
ls_k-toplam        = ls_k-toplamalacak - ls_k-toplamborc.

ls_k-topsatirsayi  = 100.
ls_k-waers         = 'TRY'.

ls_k-createdby     = sy-uname.
ls_k-createdat     = sy-datum .
*
MODIFY zsoa_elt_0001 FROM @ls_k.

 enDMETHOD.
ENDCLASS.
