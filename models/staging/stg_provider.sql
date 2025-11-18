{{ config(materialized='view') }}

select
  provider_id,
  npi,
  provider_name,
  specialty_code,
  facility_id,
  active_flag,
  updated_at
from {{ source('raw_healthcare','provider') }}
