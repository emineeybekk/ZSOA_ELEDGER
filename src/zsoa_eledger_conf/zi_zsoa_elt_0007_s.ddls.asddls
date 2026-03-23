@EndUserText.label: 'E-defter Belge Tipleri Tablosu Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'zsoa_elt_0007s'
  }
}
define root view entity ZI_zsoa_elt_0007_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_ZSOA_ELT_0007'
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_zsoa_elt_0007 as _zsoa_elt_0007
{
  @UI.facet: [ {
    id: 'ZI_zsoa_elt_0007', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'E-defter Belge Tipleri Tablosu', 
    position: 1 , 
    targetElement: '_zsoa_elt_0007'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _zsoa_elt_0007,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
