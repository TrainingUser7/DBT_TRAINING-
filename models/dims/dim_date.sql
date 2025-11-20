{{ config(materialized='table') }}
 
with params as (
  select
    dateadd('year', -3, current_date())::date as start_date,
    dateadd('year', 1, current_date())::date  as end_date
),

-- Generate a large sequence of dates (e.g., 15,000 days is about 41 years)
calendar as (
  select
    dateadd('day', seq8(), (select start_date from params))::date as dt
  -- ROWCOUNT must be a hardcoded number for the generator function to compile
  from table(generator(rowcount => 15000)) 
),

-- Filter the generated dates to the desired dynamic range
filtered_calendar as (
    select * from calendar
    where dt >= (select start_date from params) 
      and dt <= (select end_date from params)
)
 
select
  dt as date,
  to_char(dt, 'YYYY-MM-DD') as date_iso,
  extract(year from dt)::int as year,
  extract(month from dt)::int as month,
  extract(day from dt)::int as day,
  to_char(dt, 'Mon') as month_name,
  to_char(dt, 'DY') as weekday_abbrev,
  case when extract(dow from dt) in (0,6) then true else false end as is_weekend,
  date_trunc('week', dt)::date as week_start,
  date_trunc('month', dt)::date as month_start,
  date_trunc('quarter', dt)::date as quarter_start
from filtered_calendar
order by dt
