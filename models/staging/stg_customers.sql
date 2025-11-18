-- Staging model for RAW_SMARTMART.customers
-- Purpose: standardise customer keys, contact fields, basic demographic normalisation
{{ config(materialized='view') }}
 
with raw as (
  select
    customer_id,
    customer_name,
    email,
    signup_date,
    gender,
    date_of_birth,
    loyalty_tier,
    created_at,
    updated_at
  from {{ source('raw_smartmart', 'customers') }}
),
 
clean as (
  select
    trim(customer_id)                                          as customer_id,
    nullif(trim(customer_name), '')                            as customer_name,
    lower(nullif(trim(email), ''))                             as email,
    try_cast(signup_date as date)                              as signup_date,
    -- normalise gender tokens to single-letter categories where possible
    case
      when lower(trim(gender)) in ('m','male')                 then 'M'
      when lower(trim(gender)) in ('f','female')               then 'F'
      else null
    end                                                         as gender,
    try_cast(date_of_birth as date)                            as date_of_birth,
    upper(nullif(trim(loyalty_tier), ''))                      as loyalty_tier,
    try_cast(created_at as timestamp_ntz)                      as created_at,
    try_cast(updated_at as timestamp_ntz)                      as updated_at
  from raw
)
 
select * from clean
