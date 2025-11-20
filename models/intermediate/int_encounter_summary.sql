-- models/intermediate/int_encounter_summary.sql

{{ config(materialized='view') }}

with encounters as (
    select * from {{ ref('stg_encounters') }}
),

patients as (
    select * from {{ ref('stg_patients') }}
),

hospitals as (
    select * from {{ ref('stg_hospitals') }}
),

final as (

    select
        -- Encounter SK is the primary key for this model
        e.encounter_sk,
        e.encounter_id,
        
        -- Foreign keys to other dimensions
        e.patient_id,
        e.hospital_id,

        -- Encounter details
        e.encounter_date,
        e.encounter_type,
        e.length_of_stay,
        e.patient_satisfaction,

        -- Patient demographics
        p.first_name,
        p.last_name,
        p.date_of_birth,
        p.gender,
        p.insurance,

        -- Hospital details
        h.hospital_name,
        h.city as hospital_city,
        h.specialty as hospital_specialty

    from encounters e
    left join patients p      on e.patient_id = p.patient_id
    left join hospitals h     on e.hospital_id = h.hospital_id
)

select * from final
