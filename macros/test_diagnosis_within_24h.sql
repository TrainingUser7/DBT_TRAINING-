-- macros/diagnosis_within_24h.sql

-- depends_on: {{ ref('stg_diagnoses') }} 

{% macro test_diagnosis_within_24h(model) %}

-- Remove the config(dependencies=...) line if you added it previously, as the hint above is sufficient.

-- This test selects any encounters that violate the rule:
-- No encounter should exist without at least one diagnosis within 24 hours of the encounter date.
-- A non-zero return fails the test.

WITH encounters AS (
    -- 'model' here refers to the table the test is run ON, which is stg_encounters
    SELECT
        encounter_id,
        encounter_date
    FROM
        {{ model }}
),

diagnoses AS (
    -- Reference the specific diagnoses table
    SELECT
        encounter_id,
        diagnosis_id,
        diagnosis_date
    FROM
        {{ ref('stg_diagnoses') }}
),

encounters_without_timely_diagnosis AS (
    SELECT
        e.encounter_id
    FROM
        encounters e
    LEFT JOIN
        diagnoses d
        ON e.encounter_id = d.encounter_id
        -- Check if diagnosis_date is within 24 hours (1 day) of the encounter_date
        AND d.diagnosis_date BETWEEN e.encounter_date AND DATEADD(day, 1, e.encounter_date)
    WHERE
        d.diagnosis_id IS NULL -- No timely diagnosis found
)

SELECT * FROM encounters_without_timely_diagnosis

{% endmacro %}
