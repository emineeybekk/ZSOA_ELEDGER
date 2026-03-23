@EndUserText.label: 'E-defter Ödeme Tipleri Tablosu Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'zsoa_elt_0008S'
  }
}
define root view entity ZI_zsoa_elt_0008_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_ZSOA_ELT_0008'
  composition [0..*] of ZI_zsoa_elt_0008 as _zsoa_elt_0008
{
  @UI.facet: [ {
    id: 'ZI_zsoa_elt_0008', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'E-defter Ödeme Tipleri Tablosu', 
    position: 1 , 
    targetElement: '_zsoa_elt_0008'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _zsoa_elt_0008,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
