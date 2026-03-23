//@AccessControl.authorizationCheck: #NOT_ALLOWED
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Defter List DF'
//@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define root view entity ZC_SOA_EL_0002
  provider contract transactional_query
  as projection on ZI_SOA_EL_0002
{
  key RunUuid,
  key Item,
         @UI.textArrangement: #TEXT_LAST
      Status,
      StatusT,
//      @UI.textArrangement: #TEXT_LAST
//      @Consumption.valueHelpDefinition: [
//        { entity: { name: 'ZI_SOA_EL_VH_Month', element: 'Monat' } }
//      ]
      
        @Consumption.valueHelpDefinition: [{ entity: {
       name: 'ZI_SOA_EL_VH_Month',
       element: 'Monat' 
       
       } ,useForValidation: true  }]
      @Consumption.filter.multipleSelections: false
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter:{ mandatory:true }
      Monat,
      _MonatVH.MonatText as MonatText,
      Uname,
      Budat,
      Belnr,
      Ktxt,
      @Semantics.amount.currencyCode: 'Waers'
      DmbtrS,
      @Semantics.amount.currencyCode: 'Waers'
      DmbtrH,
      MaddeNo,
      Blart,
      Buzei,
      MaddeNo2,
      Hkont,
      Hkont2,
      Htext,
      Akont,
      Atext,
      @Semantics.amount.currencyCode: 'Waers'
      DmbtrDec,
      Shkzg,
      Budat2,
      Btype,
      Btext,
      Xblnr,
      Belnr2,
      Bldat,
      Otype,
      Sgtxt,
      Waers,
      Kayitno,
      @Semantics.amount.currencyCode: 'Waers'
      Dmbtr,
//      Buzei2,
      Xref2Hd,
         @UI.textArrangement: #TEXT_LAST
        @Consumption.valueHelpDefinition: [{ entity: {
       name: 'I_COMPANYCODE',
       element: 'CompanyCode' 
       
       } ,useForValidation: true  }]
      @Consumption.filter.multipleSelections: false
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter:{ mandatory:true }
      Bukrs,
           CompanyCodeName,
      @Consumption.valueHelpDefinition: [{ entity: {
       name: 'ZI_soa_el_VH_Gjahr',
       element: 'FiscalYear' 
       
       } ,useForValidation: true  }]
      @Consumption.filter.multipleSelections: false
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter:{ mandatory:true }
      Gjahr,
      Bktxt,
        _MonatVH   ,
        _CCODE  
}
