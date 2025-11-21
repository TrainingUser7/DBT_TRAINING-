{{ config(materialized='view') }}

with source as (

    select * from {{ source('carelife_raw', 'prescriptions') }}

),

staged as (

    select
        
        {{ dbt_utils.generate_surrogate_key(['prescription_id']) }} as prescription_sk,
        trim(prescription_id) as prescription_id,

        
        trim(encounter_id) as encounter_id,
        trim(patient_id) as patient_id,

        -- Dimensions/Attributes
        trim(medication) as medication,
        trim(dose) as dose,
        start_date,
        end_date,
        trim(prescribed_by) as prescribed_by

    from source

)

select * from staged
