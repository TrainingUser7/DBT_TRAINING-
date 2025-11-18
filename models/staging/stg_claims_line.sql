{{ config(materialized='view') }}

select
  claim_id,
  line_num,
  cpt_code,
  icd10_code,
  units,
  charge_amt,
  allowed_amt,
  paid_amt,
  denial_code,
  service_dt
from {{ source('raw_healthcare','claims_line') }}
