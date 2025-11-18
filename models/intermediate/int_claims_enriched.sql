{{ config(materialized='table') }}

with hdr as (
  select * from {{ ref('stg_claims_header') }}
),
ln as (
  select * from {{ ref('stg_claims_line') }}
),
prov as (
  select provider_id, specialty_code from {{ ref('stg_provider') }}
),
fac as (
  select facility_id, region from {{ ref('stg_facility') }}
)

select
  h.claim_id,
  h.member_id,
  h.provider_id,
  p.specialty_code,
  h.facility_id,
  f.region,
  h.claim_dt,
  h.claim_status,
  l.line_num,
  l.cpt_code,
  l.icd10_code,
  l.units,
  l.charge_amt,
  l.allowed_amt,
  l.paid_amt,
  l.denial_code
from hdr h
join ln  l using (claim_id)
left join prov p on h.provider_id = p.provider_id
left join fac  f on h.facility_id = f.facility_id
