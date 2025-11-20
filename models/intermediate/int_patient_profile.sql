-- models/intermediate/int_patient_profile.sql

{{ config(materialized='table') }} -- Materialize as a table for better performance on aggregations

with patients as (
    select * from {{ ref('stg_patients') }}
),

diagnoses as (
    select * from {{ ref('stg_diagnoses') }}
),

prescriptions as (
    select * from {{ ref('stg_prescriptions') }}
),

-- Aggregate diagnoses to find the latest date per patient
agg_diagnoses as (
    select
        patient_id,
        count(distinct diagnosis_id) as total_diagnoses_count,
        max(diagnosis_date) as latest_diagnosis_date
    from diagnoses
    group by patient_id
),

-- Aggregate prescriptions to find the latest date per patient
agg_prescriptions as (
    select
        patient_id,
        count(distinct prescription_id) as total_prescriptions_count,
        max(end_date) as latest_medication_end_date
    from prescriptions
    group by patient_id
),

final as (

    select
        -- Patient Details (Primary keys and demographics)
        p.patient_sk,
        p.patient_id,
        p.first_name,
        p.last_name,
        p.date_of_birth,
        p.gender,
        p.insurance,

        -- Aggregated Diagnosis Data
        ad.total_diagnoses_count,
        ad.latest_diagnosis_date,

        -- Aggregated Prescription Data
        ap.total_prescriptions_count,
        ap.latest_medication_end_date

    from patients p
    left join agg_diagnoses ad    on p.patient_id = ad.patient_id
    left join agg_prescriptions ap on p.patient_id = ap.patient_id
)

select * from final
