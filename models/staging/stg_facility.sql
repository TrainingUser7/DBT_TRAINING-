{{ config(materialized='view') }}

select
  facility_id,
  facility_name,
  facility_type,
  address_zip,
  region
from {{ source('raw_healthcare','facility') }}
