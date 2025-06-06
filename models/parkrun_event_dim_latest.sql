-- parkrun_event_dim_latest.sql
-- This model filters the snapshot to only include the current version of each parkrun event

with w_latest as (
  select *
  from {{ ref('parkrun_event_snapshot') }}
  where dbt_valid_to is null
)

select
  "parkrun ID" as event_sk,
  "eventname",
  "EventLongName",
  "EventShortName",
  "Country Name",
  "LocalisedEventLongName",
  "countrycode",
  "seriesid",
  "EventLocation",
  "Longitude",
  "Latitude",
  "Region",
  "Region Name",
  "Status",
  "Background Comment",
  "URL",
  "Final Run"
from w_latest
