//@AccessControl.authorizationCheck: #NOT_ALLOWED
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Defter Kayıt C'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@ObjectModel.semanticKey: ['RunUuid']
define root view entity ZC_SOA_EL_0001
  provider contract transactional_query
  as projection on ZI_SOA_EL_0001
{
  key RunUuid,
   @UI.textArrangement: #TEXT_LAST
//     @Consumption.valueHelpDefinition: [
//        { entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }
//      ]
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
      Printaltacc,
       @UI.textArrangement: #TEXT_LAST
      Status,
      StatusT,
      Firstymno,
      Lastymno,
      @Semantics.amount.currencyCode: 'Waers'
      Toplamalacak,
      @Semantics.amount.currencyCode: 'Waers'
      Toplamborc,
      @Semantics.amount.currencyCode: 'Waers'
      Toplam,
      Topsatirsayi,
      Waers,
      Createdby,
      Createdat,
      LocalChangedAt,
      LocalChangedBy,
      LastChangedAt,

_CCODE  ,
      _MonatVH      // <-- ZI’daki association’ı expose et (adı ZI’dakiyle aynı olmalı)
}

