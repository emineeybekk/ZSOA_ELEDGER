@AbapCatalog.sqlViewName: 'ZVHMTH01'
@EndUserText.label: 'Ay Değer Yardımı'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.dataCategory: #VALUE_HELP
define view ZI_soa_el_VH_Month 
  as select from I_Language as L
{
  key cast( '01' as abap.numc(2) ) as Monat,
       cast( 'Ocak' as zsoa_elde_0024 ) as MonatText
}
where L.Language = $session.system_language

union all select from I_Language as L { key cast( '02' as abap.numc(2) ) as Monat, 'Şubat'  as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '03' as abap.numc(2) ) as Monat, 'Mart'   as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '04' as abap.numc(2) ) as Monat, 'Nisan'  as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '05' as abap.numc(2) ) as Monat, 'Mayıs'  as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '06' as abap.numc(2) ) as Monat, 'Haziran'as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '07' as abap.numc(2) ) as Monat, 'Temmuz' as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '08' as abap.numc(2) ) as Monat, 'Ağustos'as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '09' as abap.numc(2) ) as Monat, 'Eylül'  as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '10' as abap.numc(2) ) as Monat, 'Ekim'   as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '11' as abap.numc(2) ) as Monat, 'Kasım'  as MonatText } where L.Language = $session.system_language
union all select from I_Language as L { key cast( '12' as abap.numc(2) ) as Monat, 'Aralık' as MonatText } where L.Language = $session.system_language;
