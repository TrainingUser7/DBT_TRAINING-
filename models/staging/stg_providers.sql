-- models/staging/stg_providers.sql

{{ config(materialized='view') }}

with source as (

  
    select * from {{ source('carelife_raw', 'providers') }}

),

staged as (

    select
        -- Primary Key: Use dbt_utils macro to generate a consistent surrogate key
        {{ dbt_utils.generate_surrogate_key(['provider_id']) }} as provider_sk,
        trim(provider_id) as provider_id,

        -- Dimensions
        trim(provider_name) as provider_name,
        trim(specialty) as specialty,

        -- Foreign Keys
        trim(hospital_id) as hospital_id

    from source

)

select * from staged

/*
If you get a 'dbt_utils' undefined error, make sure the package is installed
using 'dbt deps', or use the alternative below:

md5(cast(provider_id as {{ type_string() }})) as provider_sk,
*/
