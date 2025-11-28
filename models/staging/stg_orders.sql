{{ config(materialized='view') }}

select
    order_id,
    customer_id,
    ordered_at,
    status,
    order_total,
    currency,
    updated_at
from {{ source('raw', 'orders') }}
