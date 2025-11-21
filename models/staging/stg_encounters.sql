{{ config(materialized='view') }}

-- depends_on: {{ ref('stg_diagnoses') }}

with raw as (

select
  encounter_id,
  patient_id,
  primary_provider_id,
  hospital_id,
  encounter_date,
  encounter_type,
  length_of_stay,
  patient_satisfaction
from {{ source('carelife_raw','encounters') }}
),
clean as (
select 
  {{ dbt_utils.generate_surrogate_key(['encounter_id']) }} as encounter_sk, 
  trim(encounter_id) as encounter_id,
  trim(patient_id) as patient_id,
  trim(primary_provider_id) as primary_provider_id,
  trim(hospital_id) as hospital_id,
  try_cast(encounter_date as date) as encounter_date,
  encounter_type,
  try_cast(length_of_stay as number) as length_of_stay,
  CAST(patient_satisfaction as number) as patient_satisfaction
  from raw
)

select * from clean
