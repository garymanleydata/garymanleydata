-- models/date_dim.sql

WITH date_range AS (
  SELECT generate_series(
    DATE '2008-01-01',
    DATE '2030-12-31',
    INTERVAL '1 day'
  )::DATE AS date_day
)

SELECT
  date_day AS date,
  EXTRACT(YEAR FROM date_day) AS year,
  EXTRACT(MONTH FROM date_day) AS month,
  EXTRACT(DAY FROM date_day) AS day,
  EXTRACT(DOW FROM date_day) AS weekday_number,   -- 0 = Sunday
  TO_CHAR(date_day, 'Day') AS weekday_name,
  TO_CHAR(date_day, 'Month') AS month_name,
  EXTRACT(QUARTER FROM date_day) AS quarter,
  TO_CHAR(date_day, 'YYYY-MM') AS year_month,
  date_day = CURRENT_DATE AS is_today,
  date_day < CURRENT_DATE AS is_past,
  CASE WHEN EXTRACT(DOW FROM date_day) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend, 
  wd.temperature_c, 
  wd.precip_mm , 
  wd.wind_speed_mph as wind_speed_kph, 
  wd.wind_gust_mph as wind_gust_kph, 
  wd.humidity_pct , 
  wd.cloud_cover_pct, 
  case
  when temperature_c < -10 then '<-10'
  when temperature_c >= 35 then '35+'
  else concat(cast(floor(temperature_c / 5.0) * 5 as int), '-', cast(floor(temperature_c / 5.0) * 5 + 4 as int))
  end as temperature_bracket, 
  case
  when wind_speed_mph is null then 'Unknown'
  when wind_speed_mph < 0 then '<0'
  when wind_speed_mph >= 100 then '100+'
  else concat(cast(floor(wind_speed_mph / 5.0) * 5 as int), '-', cast(floor(wind_speed_mph / 5.0) * 5 + 4 as int))
end as wind_speed_bracket, 
case
  when wind_gust_mph is null then 'Unknown'
  when wind_gust_mph < 0 then '<0'
  when wind_gust_mph >= 100 then '100+'
  else concat(cast(floor(wind_gust_mph / 5.0) * 5 as int), '-', cast(floor(wind_gust_mph / 5.0) * 5 + 4 as int))
end as wind_gust_bracket, 
case
  when precip_mm is null then 'Unknown'
  when precip_mm = 0 then '0'
  when precip_mm >= 20 then '20+'
  else concat(cast(floor(precip_mm / 5.0) * 5 as int), '-', cast(floor(precip_mm / 5.0) * 5 + 4 as int))
end as precip_bracket, 
case
  when humidity_pct is null then 'Unknown'
  when humidity_pct < 0 then '<0'
  when humidity_pct >= 100 then '100'
  else concat(cast(floor(humidity_pct / 5.0) * 5 as int), '-', cast(floor(humidity_pct / 5.0) * 5 + 4 as int))
end as humidity_bracket,
case
  when cloud_cover_pct is null then 'Unknown'
  when cloud_cover_pct < 0 then '<0'
  when cloud_cover_pct >= 100 then '100'
  else concat(cast(floor(cloud_cover_pct / 5.0) * 5 as int), '-', cast(floor(cloud_cover_pct / 5.0) * 5 + 4 as int))
end as cloud_cover_bracket



FROM date_range dr
LEFT OUTER JOIN {{ source('raw', 'weather_dim') }} wd ON dr.date_day = wd.weather_date
