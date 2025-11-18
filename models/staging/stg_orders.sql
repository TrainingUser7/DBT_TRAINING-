-- Staging model for RAW_SMARTMART.orders
-- Purpose: standardise column names, cast types, basic sanity filters
{{ config(materialized='view') }}
 
with raw as (
  select
    order_id,
    customer_id,
    store_id,
    order_date,
    order_status,
    order_total,
    discount_amt,
    tax_amt,
    created_at,
    updated_at
  from {{ source('raw_smartmart', 'orders') }}
),
 
clean as (
  select
    trim(order_id)                                             as order_id,
    trim(customer_id)                                          as customer_id,
    trim(store_id)                                             as store_id,
    -- ensure date column is a DATE type (if coming as string)
    try_cast(order_date as date)                               as order_date,
    upper(trim(order_status))                                  as order_status,
    try_cast(order_total as number)                            as order_total,
    try_cast(discount_amt as number)                           as discount_amt,
    try_cast(tax_amt as number)                                as tax_amt,
    -- timestamps normalized to TIMESTAMP_NTZ if provided as string
    try_cast(created_at as timestamp_ntz)                      as created_at,
    try_cast(updated_at as timestamp_ntz)                      as updated_at
  from raw
)
 
select * from clean
 
