{{ config(materialized='view') }}

select
  member_id,
  payer_member_id,
  first_name,
  last_name,
  dob,
  sex,
  address_zip,
  plan_id,
  coverage_start_dt,
  coverage_end_dt,
  status,
  updated_at
from {{ source('raw_healthcare','member_enrollment') }}
