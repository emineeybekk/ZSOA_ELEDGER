@EndUserText.label: 'E-Defter Şirket Kodu VKN Tablosu Singlet'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'zsoa_elt_0009s'
  }
}
define root view entity ZI_zsoa_elt_0009_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_ZSOA_ELT_0009'
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_ZSOA_ELT_0009 as _ZSOA_ELT_0009
{
  @UI.facet: [ {
    id: 'ZI_ZSOA_ELT_0009', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'E-Defter Şirket Kodu VKN Tablosu', 
    position: 1 , 
    targetElement: '_ZSOA_ELT_0009'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _ZSOA_ELT_0009,
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
