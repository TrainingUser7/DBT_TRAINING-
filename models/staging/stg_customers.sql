{{ config(materialized='view') }}

select
    customer_id,
    customer_name,
    email,
    country,
    first_order_date,
    created_at,
    updated_at
from {{ source('raw', 'customers') }}
