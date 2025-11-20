{{ config(materialized='view') }}

with source as (

    -- Reference the raw source using the source() macro
    -- Source name updated to 'carelife_raw' as requested
    select * from {{ source('carelife_raw', 'prescriptions') }}

),

staged as (

    select
        -- Primary Key: Generate a surrogate key for consistent, non-varchar PKs
        {{ dbt_utils.generate_surrogate_key(['prescription_id']) }} as prescription_sk,
        trim(prescription_id) as prescription_id,

        -- Foreign Keys
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
