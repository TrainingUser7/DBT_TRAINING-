{% snapshot snap_member_enrollment %}

{{
  config(
    target_database='HEALTHCARE_ANALYTICS_DB',
    target_schema='ANALYTICS_HEALTHCARE',
    unique_key='member_id',
    strategy='timestamp',
    updated_at='updated_at',
    invalidate_hard_deletes=True
  )
}}

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

{% endsnapshot %}
