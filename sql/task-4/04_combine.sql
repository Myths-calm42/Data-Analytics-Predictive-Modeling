-- TASK 4 STEP 4 — COMBINE FEATURES + TARGET
-- Features come only from data on/before prediction_date.
-- churn_14d comes only from the subsequent 14 days.

WITH features AS (
    -- Replace this CTE with the result of 03_features.sql in a notebook,
    -- or create a temporary view named task4_features before running this file.
    SELECT * FROM task4_features
),

labels AS (
    -- Replace this CTE with the result of 02_churn_label.sql in a notebook,
    -- or create a temporary view named task4_labels before running this file.
    SELECT * FROM task4_labels
)

SELECT
    f.*,
    l.churn_14d
FROM features f
JOIN labels l
  ON l.device_id = f.device_id
 AND l.prediction_date = f.prediction_date
ORDER BY
    f.prediction_date,
    f.device_id;
