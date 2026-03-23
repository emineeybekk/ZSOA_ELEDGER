//@AccessControl.authorizationCheck: #NOT_ALLOWED
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Defter Kayıt DF'
//@Metadata.ignorePropagatedAnnotations: true
//@Metadata.allowExtensions: true
define root view entity ZI_SOA_EL_0001
  as select from zsoa_elt_0001
  association [0..1] to ZI_soa_el_VH_Month as _MonatVH on _MonatVH.Monat = $projection.Monat
  association [0..1] to I_CompanyCode      as _CCODE   on _CCODE.CompanyCode = $projection.Bukrs
{
  key run_uuid               as RunUuid,

      @ObjectModel.text.element: ['CompanyCodeName']
      @UI.textArrangement: #TEXT_LAST
      bukrs                  as Bukrs,
      _CCODE.CompanyCodeName as CompanyCodeName,
      gjahr                  as Gjahr,
      rldnr                  as Rldnr,

      @ObjectModel.text.element: ['MonatText']
      @UI.textArrangement: #TEXT_LAST
      monat                  as Monat,
      _MonatVH, // sadece expose
      //       @Semantics.text: true

      _MonatVH.MonatText     as MonatText,
      printaltacc            as Printaltacc,
      @ObjectModel.text.element: ['StatusT']
      @UI.textArrangement: #TEXT_LAST
      status                 as Status,
      case
       when status = '1' then  'Yeni'
       when status = '2' then  'İşlendi'
       when status = '3' then  'CSV Oluştu'
       else  ''
       end                   as StatusT,
      firstymno              as Firstymno,
      lastymno               as Lastymno,
      @Semantics.amount.currencyCode: 'Waers'
      toplamalacak           as Toplamalacak,
      @Semantics.amount.currencyCode: 'Waers'
      toplamborc             as Toplamborc,
      @Semantics.amount.currencyCode: 'Waers'
      toplam                 as Toplam,
      topsatirsayi           as Topsatirsayi,
      waers                  as Waers,
      @Semantics.user.createdBy: true
      createdby              as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat              as Createdat,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalChangedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by  as LocalChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      _CCODE
}
