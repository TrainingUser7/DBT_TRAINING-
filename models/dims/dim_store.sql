{{ config(materialized='table') }}
 
select
  s.store_id,
  s.store_name,
  s.region_id,
  r.region_name,
  s.store_open_date,
  s.store_type
from {{ ref('stg_stores') }} s
left join {{ ref('stg_regions') }} r on s.region_id = r.region_id
 
