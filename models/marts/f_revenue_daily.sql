{{ config(materialized='table') }}

select
  claim_dt,
  region,
  facility_id,
  provider_id,
  sum(charge_amt) as total_charges,
  sum(allowed_amt) as total_allowed,
  sum(paid_amt)    as total_paid,
  sum(iff(denial_code is not null, 1, 0)) as denied_lines,
  {{ safe_div('sum(paid_amt)', 'nullif(sum(allowed_amt), 0)') }} as pay_to_allowed_ratio
from {{ ref('int_claims_enriched') }}
group by 1,2,3,4
