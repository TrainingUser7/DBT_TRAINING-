{{ config(materialized='table') }}
 
-- Produces a date dimension for a useful range (adjust start/end as needed)
with params as (
  select
    dateadd('year', -3, current_date())::date as start_date,
    dateadd('year', 1, current_date())::date  as end_date
),
calendar as (
  select
    dateadd('day', row_number() over (order by seq8()) - 1, (select start_date from params))::date as dt
  from table(generator(rowcount => datediff('day', (select start_date from params), (select end_date from params)) + 1))
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
from calendar
order by dt
 
