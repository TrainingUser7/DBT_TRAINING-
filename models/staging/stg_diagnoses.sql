{{ config(materialized='view') }}

with raw as (

select
  diagnosis_id,
  encounter_id,
  patient_id,
  diagnosis_code,
  description,
  diagnosis_date
from {{ source('carelife_raw','diagnoses') }}
),
clean as (
select 
  {{ dbt_utils.generate_surrogate_key(['diagnosis_id']) }} as diagnosis_sk,
  trim(diagnosis_id) as diagnosis_id,
  trim(encounter_id) as encounter_id,
  trim(patient_id) as patient_id,
  diagnosis_code,
  description,
  try_cast(diagnosis_date as date) as diagnosis_date
  from raw
)

select * from clean