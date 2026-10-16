-- TASK 4 STEP 1
-- Prediction dates are Feb 1 through Apr 16, 2026.
-- Feb 1 gives us a complete 30-day lookback from Jan onward.
-- Apr 16 is the latest date with a complete 14-day outcome through Apr 30.

SELECT
    prediction_date
FROM generate_series(
    DATE '2026-02-01',
    DATE '2026-04-16',
    INTERVAL '1 day'
) AS t(prediction_date)
ORDER BY prediction_date;
