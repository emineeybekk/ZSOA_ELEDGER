@EndUserText.label: 'E-Defter Hesap Metinleri'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_zsoa_elt_0006
  as select from ZSOA_ELT_0006
  association to parent ZI_zsoa_elt_0006_S as _zsoa_elt_0006S on $projection.SingletonID = _zsoa_elt_0006S.SingletonID
{
  key HKONT as Hkont,
  TEXT as Text_000,
  @Consumption.hidden: true
  1 as SingletonID,
  _zsoa_elt_0006S
}
