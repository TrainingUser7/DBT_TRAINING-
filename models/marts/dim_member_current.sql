{{ config(materialized='view') }}

select *
from {{ ref('snap_member_enrollment') }}
where dbt_valid_to is null
