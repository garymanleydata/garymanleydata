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
  CASE WHEN EXTRACT(DOW FROM date_day) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_range

