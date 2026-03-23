@EndUserText.label: 'CSV İşlemleri DD'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_SOA_EL_0005 
  provider contract transactional_query
  as projection on  ZI_SOA_EL_0005
{

     key RunUuid,
      @UI.textArrangement: #TEXT_LAST
        @Consumption.valueHelpDefinition: [
        { entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }
      ]
      Bukrs,
      
      CompanyCodeName,
      Gjahr,
      Rldnr,

      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [
        { entity: { name: 'ZI_SOA_EL_VH_Month', element: 'Monat' } }
      ]
      Monat,
     _MonatVH.MonatText     as MonatText,
    Attachment,
    Mimetype,
    Filename,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
    
}
