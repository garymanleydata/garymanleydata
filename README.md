# 🏃 parkrun Analytics with dbt + Supabase

A dbt project for modeling and analysing personal and public parkrun data. This pipeline integrates CSVs, weather APIs, email ingestion, and snapshots to create a comprehensive view of parkrun performance, conditions, and history.

---

## 📁 Project Structure

### 📦 Data Sources

| Source                           | Description                                                            |
|----------------------------------|------------------------------------------------------------------------|
| `landing_parkrun_event`          | Raw event metadata CSV ingested via GitHub Actions                     |
| `personal_parkrun_result`        | Email-based personal parkrun result ingestion (via IMAP + Python)      |
| `dim_weather`                    | Daily 9am historical weather via Meteomatics API                       |
| `landing_weather_forecast`       | Latest daily weather forecast (truncated and loaded daily)             |
| `land_bank_holiday`              | UK bank holiday calendar (loaded monthly from gov.uk API)              |

---

## 🧱 dbt Models & Snapshots

### 🗃️ Snapshots

| Snapshot                     | Description                                                |
|-----------------------------|------------------------------------------------------------|
| `parkrun_event_snapshot`    | SCD2 snapshot of all parkrun events (from master CSV list) |
| `scd2_weather_forecast`     | SCD2 snapshot of daily weather forecasts for Eastbourne    |

### 🧩 Dimensional Models

| Model                          | Description                                                           |
|--------------------------------|-----------------------------------------------------------------------|
| `parkrun_event_dim_latest`     | Current version of parkrun events (`dbt_valid_to is null`)           |
| `transformed_personal_parkrun`| Cleaned and filtered personal results for performance analysis       |
| `date_dim`                     | dbt-generated calendar with added holiday info                        |

---

## 🔄 Scheduling

- All dbt models and snapshots are run on a daily schedule via **dbt Cloud**.
- The `snapshot` step runs **before** `dbt build` to ensure up-to-date SCD2 data.

---

## 🔍 Analytic Enrichment

- ❄️ **Weather**: Matches daily conditions to events and training
- 📆 **Holidays**: UK bank holiday data joins the `date_dim`
- 🏃 **Outlier exclusion**: Manual list of pacing/volunteering events used for filtering


---

##  BI

The data is currently being analysed in PowerBI and Google Looker Studio.


## 🛠️ TODO (WIP)

- [ ] Add Strava integration: full activity data + metrics
- [ ] Add exclusion data i.e. days when I am pacing or not pushing should optional when modelling or presenting the data. 
- [ ] Build Streamlit app / machine learning models to explore training/weather impact on parkrun times
- [ ] Derive or fetch parkrun elevation data
---

## 🤝 Contributing

This is a personal project. If you’re working on something similar, feel free to get in touch

