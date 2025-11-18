-- Staging model for RAW_SMARTMART.regions
-- Purpose: canonical region lookup table staging
{{ config(materialized='view') }}
 
with raw as (
  select
    region_id,
    region_name,
    created_at
  from {{ source('raw_smartmart', 'regions') }}
),
 
clean as (
  select
    trim(region_id)                                            as region_id,
    nullif(trim(region_name), '')                              as region_name,
    created_at                                                 as created_at
  from raw
)
 
select * from clean
 
