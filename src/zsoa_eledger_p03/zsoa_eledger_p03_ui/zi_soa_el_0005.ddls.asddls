@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CSV İşlemleri DD'
define root view entity ZI_SOA_EL_0005
  as select from zsoa_elt_0005
   association [0..1] to ZI_soa_el_VH_Month as _MonatVH on _MonatVH.Monat = $projection.Monat
 association [0..1] to I_CompanyCode      as _CCODE   on _CCODE.CompanyCode = $projection.Bukrs
{
    key run_uuid              as RunUuid,
    @ObjectModel.text.element: ['CompanyCodeName']
      @UI.textArrangement: #TEXT_LAST
      bukrs                 as Bukrs,
      _CCODE,
      _CCODE.CompanyCodeName as CompanyCodeName,
      gjahr                 as Gjahr,
      rldnr                 as Rldnr,
      @ObjectModel.text.element: ['MonatText']
      @UI.textArrangement: #TEXT_LAST
      monat                 as Monat,
      _MonatVH, // sadece expose
      //       @Semantics.text: true
      
      _MonatVH.MonatText    as MonatText,
      @Semantics.largeObject:
       { mimeType: 'MimeType',
       fileName: 'Filename',
       contentDispositionPreference: #INLINE }
      attachment            as Attachment,
      @Semantics.mimeType: true
      mimetype              as Mimetype,
      filename              as Filename,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt
}
