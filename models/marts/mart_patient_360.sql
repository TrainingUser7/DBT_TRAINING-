-- models/marts/mart_patient_360.sql
-- Provides a single row per patient with summary statistics

{{ config(materialized='table') }}

with patient_profiles as (
    select * from {{ ref('int_patient_profile') }}
),

encounters as (
    select * from {{ ref('stg_encounters') }}
),

diagnoses as (
    select * from {{ ref('stg_diagnoses') }}
),

-- Step 1: Tag the last hospital visited using a window function across all encounters
tagged_last_hospital as (
    select
        *,
        last_value(hospital_id) over (
            partition by patient_id
            order by encounter_date rows between unbounded preceding and unbounded following
        ) as last_hospital_visited_id
    from encounters
),

-- Step 2: Aggregate metrics (total visits) and pull the last hospital ID using a simple max/min
agg_encounters as (
    select
        patient_id,
        count(encounter_id) as total_visits,
        -- Now we can use MIN/MAX on the pre-calculated 'last_hospital_visited_id'
        max(last_hospital_visited_id) as last_hospital_id 
    from tagged_last_hospital
    group by patient_id
),

-- Aggregate diagnoses to list chronic conditions (logic remains the same)
agg_conditions as (
    select
        patient_id,
        array_agg(distinct diagnosis_code) as chronic_conditions_codes
    from diagnoses
    -- Filter for common chronic condition prefixes (e.g., ICD-10 codes)
    where diagnosis_code like 'E10%' or diagnosis_code like 'I10%'
    group by patient_id
),

final as (
    select
        -- Basic demographics
        pp.patient_sk,
        pp.patient_id,
        pp.first_name,
        pp.last_name,
        pp.date_of_birth,
        pp.gender,
        pp.insurance,

        -- Metrics
        ae.total_visits,
        ac.chronic_conditions_codes,

        -- Most recent info from int_patient_profile
        pp.latest_diagnosis_date as most_recent_diagnosis_date,
        pp.latest_medication_end_date as most_recent_prescription_end_date,

        -- Hospital last visited
        ae.last_hospital_id
        
    from patient_profiles pp
    left join agg_encounters ae on pp.patient_id = ae.patient_id
    left join agg_conditions ac on pp.patient_id = ac.patient_id
)

select * from final
