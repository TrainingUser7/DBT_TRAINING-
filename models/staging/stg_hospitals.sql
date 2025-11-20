{{ config(materialized='view') }}

with raw as 
(
  -- Corrected: 'Sel' changed to 'select' and removed double 'from'
  select * from {{ source('carelife_raw','hospitals') }}
),

clean as (
select
  -- Added aliases for trimmed columns
  {{ dbt_utils.generate_surrogate_key(['hospital_id']) }} as hospital_sk,
  trim(hospital_id) as hospital_id,
  hospital_name,
  trim(city) as city,
  trim(specialty) as specialty
from raw
)

select * from clean
