-- Staging model for RAW_SMARTMART.order_items
-- Purpose: normalise numeric types, flatten basic product text, ensure line-level numeric sanity
{{ config(materialized='view') }}
 
with raw as (
  select
    order_id,
    line_num,
    product_sku,
    product_name,
    quantity,
    unit_price,
    extended_price,
    discount_amt,
    created_at
  from {{ source('raw_smartmart', 'order_items') }}
),
 
clean as (
  select
    trim(order_id)                                             as order_id,
    cast(line_num as integer)                              as line_num,
    trim(product_sku)                                          as product_sku,
    nullif(trim(product_name), '')                             as product_name,
    cast(quantity as integer)                              as quantity,
    cast(unit_price as number)                             as unit_price,
    cast(extended_price as number)                         as extended_price,
    cast(discount_amt as number)                           as discount_amt,
    created_at                                                as created_at
  from raw
),
 
-- Basic data quality: ensure extended_price approximates quantity * unit_price when both present
validated as (
  select
    *,
    case
      when extended_price is null and quantity is not null and unit_price is not null
        then quantity * unit_price
      else extended_price
    end as extended_price_calculated
  from clean
)
 
select
  order_id,
  line_num,
  product_sku,
  product_name,
  quantity,
  unit_price,
  coalesce(extended_price, extended_price_calculated) as extended_price,
  discount_amt,
  created_at
from validated
