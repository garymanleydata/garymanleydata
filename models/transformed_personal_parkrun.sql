-- models/transformed_personal_parkrun.sql

with w_cleansed as (
SELECT
trim(regexp_replace(lower("Event"), '[\t\r\n]+', '')) as "Event",
  to_date("Run Date",'DD/MM/YYYY') "Run Date",
  "Run Number",
  "Pos",
  "Age Grade",
  "PB?",
  CASE
    -- Case 1: HH:MM:SS → convert to MM:SS
    WHEN length("Time") = 8 AND split_part("Time", ':', 3) <> '00' THEN
      LPAD(CAST(60 * CAST(split_part("Time", ':', 1) AS INT) +
                CAST(split_part("Time", ':', 2) AS INT) AS VARCHAR), 2, '0') || ':' ||
      LPAD(split_part("Time", ':', 3), 2, '0')
    
    -- Case 2: MM:SS:00 → drop trailing :00
    WHEN length("Time") = 8 AND split_part("Time", ':', 3) = '00' THEN
      split_part("Time", ':', 1) || ':' || split_part("Time", ':', 2)

    -- Case 3: Already valid MM:SS
    ELSE "Time"
  END AS CleanedTime

FROM {{ source('raw', 'personal_parkrun_result') }}

  )
  , w_clean2 as (
select c.*, 
  CAST(split_part(CleanedTime, ':', 1) AS INT) AS vMinutes,
    CAST(split_part(CleanedTime, ':', 2) AS INT) AS vSeconds,
    CAST(split_part(CleanedTime, ':', 1) AS INT) * 60 + 
    CAST(split_part(CleanedTime, ':', 2) AS INT) AS vTotalSeconds, 
  ROUND(CAST(REPLACE("Age Grade", '%', '') AS numeric) / 100,4) AS decimalAG, 
  case when "PB?" = 'PB' THEN 'Yes' Else 'No' end as "PB Indicator"
  from w_cleansed c
  )
  select c2.* , 
   vTotalSeconds = MIN(vTotalSeconds) OVER (ORDER BY "Run Date" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS overall_pb,
   ed.event_sk
  FROM w_clean2 c2
  INNER JOIN {{ ref('event_dim') }} ed on lower(c2."Event") = ed.event_name