@EndUserText.label: 'E-defter Belge Tipleri Tablosu'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_zsoa_elt_0007
  as select from ZSOA_ELT_0007
  association to parent ZI_zsoa_elt_0007_S as _zsoa_elt_0007s on $projection.SingletonID = _zsoa_elt_0007s.SingletonID
{
  key BLART as Blart,
  BTYPE as Btype,
  BTEXT as Btext,
  MODUL as Modul,
  @Consumption.hidden: true
  1 as SingletonID,
  _zsoa_elt_0007s
}
