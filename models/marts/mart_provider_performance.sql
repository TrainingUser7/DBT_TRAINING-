-- models/marts/mart_provider_performance.sql
-- Provides a single row per provider with performance metrics

{{ config(materialized='table') }}

with providers as (
    select * from {{ ref('stg_providers') }}
),

encounters as (
    select * from {{ ref('stg_encounters') }}
),

diagnoses as (
    select * from {{ ref('stg_diagnoses') }}
),

-- Step 1: Determine which patients have repeat visits across the whole system
patient_visit_counts as (
    select
        patient_id,
        count(encounter_id) as total_patient_encounters
    from encounters
    group by patient_id
),

-- Step 2: Aggregate metrics per provider, using standard aggregates
agg_encounters as (
    select
        primary_provider_id,
        count(encounter_id) as number_of_encounters_handled,
        avg(patient_satisfaction) as avg_patient_satisfaction_score
    from encounters
    group by primary_provider_id
),

-- Step 3: Count ONLY the repeat visits associated with this specific provider
agg_repeat_visits as (
    select 
        e.primary_provider_id,
        count(e.encounter_id) as number_of_repeat_visits
    from encounters e
    join patient_visit_counts pvc 
        on e.patient_id = pvc.patient_id
    where pvc.total_patient_encounters > 1 -- Only count encounters for repeat patients
    group by e.primary_provider_id
),

-- Step 4: Find the most common diagnosis treated by each provider (logic remains the same)
agg_diagnoses as (
    select
        e.primary_provider_id,
        first_value(d.description) over (
            partition by e.primary_provider_id
            order by count(d.diagnosis_id) desc
        ) as most_common_diagnosis_treated
    from encounters e
    join diagnoses d on e.encounter_id = d.encounter_id
    group by e.primary_provider_id, d.description
),

final as (
    select
        p.provider_sk,
        p.provider_id,
        p.provider_name,
        p.specialty,
        
        ae.number_of_encounters_handled,
        ae.avg_patient_satisfaction_score,
        arv.number_of_repeat_visits, -- Join in the separate repeat visit count
        ad.most_common_diagnosis_treated

    from providers p
    left join agg_encounters ae     on p.provider_id = ae.primary_provider_id
    left join agg_repeat_visits arv on p.provider_id = arv.primary_provider_id
    left join agg_diagnoses ad      on p.provider_id = ad.primary_provider_id
)

select * from final
