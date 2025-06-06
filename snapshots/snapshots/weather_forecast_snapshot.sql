{% snapshot scd2_weather_forecast %}
{{
    config(
        target_schema='snapshots',
        unique_key='forecast_time',
        strategy='check',
        check_cols=[
            'temperature_c',
            'wind_speed_kmh',
            'wind_gusts_kmh',
            'humidity_pct',
            'precip_mm',
            'cloud_cover_pct'
        ]
    )
}}

select
    forecast_time,
    location,
    temperature_c,
    wind_speed_kmh,
    wind_gusts_kmh,
    humidity_pct,
    precip_mm,
    cloud_cover_pct
from {{ source('raw', 'landing_weather_forecast') }}

{% endsnapshot %}
