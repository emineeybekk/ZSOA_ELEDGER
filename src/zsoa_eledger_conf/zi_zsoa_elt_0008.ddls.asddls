@EndUserText.label: 'E-defter Ödeme Tipleri Tablosu'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_zsoa_elt_0008
  as select from ZSOA_ELT_0008
  association to parent ZI_zsoa_elt_0008_S as _zsoa_elt_0008S on $projection.SingletonID = _zsoa_elt_0008S.SingletonID
{
  key BLART as Blart,
  OTYPE as Otype,
  @Consumption.hidden: true
  1 as SingletonID,
  _zsoa_elt_0008S
}
