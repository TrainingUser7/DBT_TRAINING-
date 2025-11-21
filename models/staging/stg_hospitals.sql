{{ config(materialized='view') }}

with raw as 
(
  
  select * from {{ source('carelife_raw','hospitals') }}
),

clean as (
select
  
  {{ dbt_utils.generate_surrogate_key(['hospital_id']) }} as hospital_sk,
  trim(hospital_id) as hospital_id,
  hospital_name,
  trim(city) as city,
  trim(specialty) as specialty
from raw
)

select * from clean
