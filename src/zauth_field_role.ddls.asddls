@AbapCatalog.sqlViewName: 'zauth_r_fv'
define view zauth_field_role as select from agr_1251 as v
  association to agr_1252 as o on v.agr_name = o.agr_name and v.low = o.varbl {

  key v.agr_name,
  key v.counter,
  v.object,
  v.auth,
  v.field,
  coalesce( o.low, v.low ) as low,
  coalesce( o.high, v.high ) as high,
  v.modified,
  v.deleted,
  v.copied,
  v.neu
}
