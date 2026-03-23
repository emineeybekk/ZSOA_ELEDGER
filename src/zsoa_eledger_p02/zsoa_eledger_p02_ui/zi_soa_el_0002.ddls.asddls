//@AccessControl.authorizationCheck: #NOT_ALLOWED
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Defter List BO view'
//@Metadata.ignorePropagatedAnnotations: true
//@Metadata.allowExtensions: true

define root view entity ZI_SOA_EL_0002
  as select from zsoa_elt_0002
  association [0..1] to ZI_soa_el_VH_Month as _MonatVH on _MonatVH.Monat = $projection.Monat
   association [0..1] to zsoa_elt_0001 as _z1 on _z1.run_uuid = $projection.RunUuid
    association [0..1] to I_CompanyCode      as _CCODE   on _CCODE.CompanyCode = $projection.Bukrs
{
  key run_uuid  as RunUuid,
  key item      as Item,

 @ObjectModel.text.element: ['StatusT']
      @UI.textArrangement: #TEXT_LAST
      _z1.status                 as Status,
      case
       when _z1.status = '1' then  'Yeni'
       when _z1.status = '2' then  'İşlendi'
       when _z1.status = '3' then  'CSV Oluştu'
       else  ''
       end                   as StatusT,
       
       monat                 as Monat,
      _MonatVH, // sadece expose
      //       @Semantics.text: true
      uname     as Uname,
      budat     as Budat,
      belnr     as Belnr,
      ktxt      as Ktxt,
      @Semantics.amount.currencyCode: 'Waers'
      dmbtr_s   as DmbtrS,
      @Semantics.amount.currencyCode: 'Waers'
      dmbtr_h   as DmbtrH,
      madde_no  as MaddeNo,
      blart     as Blart,
      buzei     as Buzei,
      madde_no2 as MaddeNo2,
      hkont     as Hkont,
//       hkont2     as Hkont2,
lpad( hkont2, 3, '0' ) as Hkont2,
      htext     as Htext,
      akont     as Akont,
      atext     as Atext,
      @Semantics.amount.currencyCode: 'Waers'
      dmbtr_dec as DmbtrDec,
      shkzg     as Shkzg,
      budat2    as Budat2,
      btype     as Btype,
      btext     as Btext,
      xblnr     as Xblnr,
      belnr2    as Belnr2,
      bldat     as Bldat,
      otype     as Otype,
      sgtxt     as Sgtxt,
      waers     as Waers,
      kayitno   as Kayitno,
      @Semantics.amount.currencyCode: 'Waers'
      dmbtr     as Dmbtr,
//      buzei2    as Buzei2,
      xref2_hd  as Xref2Hd,
      
      bukrs     as Bukrs,
       _CCODE.CompanyCodeName as CompanyCodeName,
      gjahr     as Gjahr,
      bktxt     as Bktxt,
       _CCODE 
}
