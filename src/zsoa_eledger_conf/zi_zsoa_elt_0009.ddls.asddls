@EndUserText.label: 'E-Defter Şirket Kodu VKN Tablosu'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ZSOA_ELT_0009
  as select from ZSOA_ELT_0009
  association to parent ZI_zsoa_elt_0009_S as _zsoa_elt_0009s on $projection.SingletonID = _zsoa_elt_0009s.SingletonID
{
  key BUKRS as Bukrs,
  STCD2 as Stcd2,
  @Consumption.hidden: true
  1 as SingletonID,
  _zsoa_elt_0009s
}
