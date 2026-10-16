-- TASK 4 STEP 2 — TARGET
-- Churn definition:
-- A player is currently active if they have >=1 player_day record
-- in the 7-day window ending on prediction_date.
-- churn_14d = 1 if they have NO player_day record in the following 14 days.
-- The future window is strictly after prediction_date.

WITH activity AS (
    SELECT
        device_id,
        CAST(
            STRPTIME(CAST(activity_date AS VARCHAR), '%Y%m%d')
            AS DATE
        ) AS activity_date
    FROM player_day
),

prediction_dates AS (
    SELECT prediction_date
    FROM generate_series(
        DATE '2026-02-01',
        DATE '2026-04-16',
        INTERVAL '1 day'
    ) AS t(prediction_date)
),

active_players AS (
    SELECT DISTINCT
        a.device_id,
        d.prediction_date
    FROM prediction_dates d
    JOIN activity a
      ON a.activity_date BETWEEN
         d.prediction_date - INTERVAL '6 days'
         AND d.prediction_date
)

SELECT
    ap.device_id,
    ap.prediction_date,
    CASE
        WHEN COUNT(f.device_id) = 0 THEN 1
        ELSE 0
    END AS churn_14d
FROM active_players ap
LEFT JOIN activity f
  ON f.device_id = ap.device_id
 AND f.activity_date > ap.prediction_date
 AND f.activity_date <= ap.prediction_date + INTERVAL '14 days'
GROUP BY
    ap.device_id,
    ap.prediction_date
ORDER BY
    ap.prediction_date,
    ap.device_id;
