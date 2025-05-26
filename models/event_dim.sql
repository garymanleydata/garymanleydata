with w_parkruns as (
    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part("Venue", ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name
    FROM {{ source('raw', 'parkrun_sss_2025') }}

    union 

    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part(replace("parkrun full name",' parkrun',''), ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name
    FROM {{ source('raw', 'parkrun_event_details') }}

    union

    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part(replace("Short_name",' parkrun',''), ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name
    FROM {{ source('raw', 'parkrun_event_location') }}
), 

w_sss as (
    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part("Venue", ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name, s.*
    FROM {{ source('raw', 'parkrun_sss_2025') }} s
), 

w_sss2 as (
    SELECT ws.*, 
           ROW_NUMBER() OVER (PARTITION BY event_name ORDER BY "Venue") AS route_number
    FROM w_sss ws
), 

w_sss_final as (
    SELECT
      event_name,
      MAX(CASE WHEN route_number = 1 THEN "SSS" END) AS sss_route_1,
      MAX(CASE WHEN route_number = 2 THEN "SSS" END) AS sss_route_2,
      MAX(CASE WHEN route_number = 1 THEN "Rank" END) AS rank_route_1,
      MAX(CASE WHEN route_number = 2 THEN "Rank" END) AS rank_route_2,
      MAX(CASE WHEN route_number = 1 THEN "Venue" END) AS venue_route_1,
      MAX(CASE WHEN route_number = 2 THEN "Venue" END) AS venue_route_2
    FROM w_sss2
    GROUP BY event_name
), 

w_ev as (
    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part(replace("parkrun full name",' parkrun',''), ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name, e.*
    FROM {{ source('raw', 'parkrun_event_details') }} e
), 

w_ev2 as (
    SELECT ws.*, 
           ROW_NUMBER() OVER (PARTITION BY event_name ORDER BY "parkrun full name") AS route_number
    FROM w_ev ws
), 

w_loc as (
    SELECT 
      lower(trim(
        replace(replace(replace(replace(
          split_part(replace("Short_name",' parkrun',''), ',', 1),
          '(Summer)', ''
        ), '(Winter)', ''), '(Main)', ''), '(Alternative)', '')
      )) AS event_name, *
    FROM {{ source('raw', 'parkrun_event_location') }}
)
,w_final as(
SELECT
  wp.event_name,
  sss.sss_route_1,
  sss.sss_route_2,
  sss.rank_route_1,
  sss.rank_route_2,
  sss.venue_route_1,
  sss.venue_route_2,
  ev."parkrun full name",
  ev.location,
  ev.region,
  ev.laps,
  ev.terrain,
  ev."#WhatShoes?" AS Shoe_rec,
  ev.comments,
  loc."Shape" AS route_type,
  loc."Short_name" AS Short_name,
  loc."Latitude" AS Latitude,
  loc."Longitude" AS Longitude

FROM w_parkruns wp
LEFT OUTER JOIN w_sss_final sss ON wp.event_name = sss.event_name
LEFT OUTER JOIN w_ev2 ev ON wp.event_name = ev.event_name AND ev.route_number = 1
LEFT OUTER JOIN w_loc loc ON wp.event_name = loc.event_name
WHERE wp.event_name IS NOT NULL
)
select w.*, 
{{ dbt_utils.generate_surrogate_key(['event_name']) }} AS event_sk
from w_final w