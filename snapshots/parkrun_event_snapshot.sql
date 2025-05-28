{% snapshot parkrun_event_snapshot %}

{{ config(
    target_schema = "snapshots",
    unique_key = "\"parkrun ID\"",
    strategy = "check",
    check_cols = [
  "\"eventname\"",
  "\"EventLongName\"",
  "\"EventShortName\"",
  "\"Country Name\"",
  "\"LocalisedEventLongName\"",
  "\"countrycode\"",
  "\"seriesid\"",
  "\"EventLocation\"",
  "\"Longitude\"",
  "\"Latitude\"",
  "\"Region\"",
  "\"Region Name\"",
  "\"Status\"",
  "\"Background Comment\"",
  "\"URL\"",
  "\"Final Run\""    ],
    invalidate_hard_deletes = true
  )
 }}

select *
from {{ source('raw', 'landing_parkrun_event') }}

{% endsnapshot %}
