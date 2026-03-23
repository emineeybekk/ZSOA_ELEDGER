@EndUserText.label: 'Yıl CDS'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.dataCategory: #VALUE_HELP
@UI.presentationVariant: [{
  sortOrder: [
    { by: 'FiscalYear', direction: #DESC }
  ]
}]
define view entity ZI_soa_el_VH_Gjahr  as select distinct from I_FiscalYear
{
  key FiscalYear 
} 
