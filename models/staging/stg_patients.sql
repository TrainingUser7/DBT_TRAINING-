{{ config(materialized='view') }}

with raw as (

select
  patient_id,
  first_name,
  last_name,
  date_of_birth,
  gender,
  phone,
  address,
  insurance
from {{ source('carelife_raw','patients') }}
),
clean as (
select 
 {{ dbt_utils.generate_surrogate_key(['patient_id']) }} as patient_sk,
 trim(patient_id) as patient_id,
  trim(first_name) as first_name,
  trim(last_name) as last_name,
  try_cast(date_of_birth as date) as date_of_birth,
  trim(gender) as gender,
  try_cast(phone as number) as phone,
  address,
  trim(insurance) as insurance
  from raw
)

select * from clean
