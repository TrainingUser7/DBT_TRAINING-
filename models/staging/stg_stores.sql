-- Staging model for RAW_SMARTMART.stores
-- Purpose: standardise store master data and joinable keys
{{ config(materialized='view') }}
 
with raw as (
  select
    store_id,
    store_name,
    region_id,
    store_open_date,
    store_type,
    created_at
  from {{ source('raw_smartmart', 'stores') }}
),
 
clean as (
  select
    trim(store_id)                                             as store_id,
    nullif(trim(store_name), '')                               as store_name,
    trim(region_id)                                            as region_id,
    try_cast(store_open_date as date)                          as store_open_date,
    upper(nullif(trim(store_type), ''))                        as store_type,
    created_at                                                 as created_at
  from raw
)
 
select * from clean
