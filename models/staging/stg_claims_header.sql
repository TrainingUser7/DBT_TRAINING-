{{ config(materialized='view') }}

select
  claim_id,
  member_id,
  provider_id,
  facility_id,
  claim_dt,
  claim_status,
  total_charges,
  total_paid,
  updated_at
from {{ source('raw_healthcare','claims_header') }}
