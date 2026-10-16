-- Overall ARPDAU: first 30 days vs last 30 days
WITH daily_active AS (
    SELECT
        STRPTIME(CAST(pd.activity_date AS VARCHAR), '%Y%m%d')::DATE AS activity_date,
        COUNT(DISTINCT pd.device_id) AS dau
    FROM player_day pd
    JOIN player_profile pp USING (device_id)
    WHERE pd.activity_date BETWEEN 20260101 AND 20260430
    GROUP BY 1
), daily_revenue AS (
    SELECT
        CAST(p.event_ts AS DATE) AS activity_date,
        SUM(p.usd_amount) AS revenue
    FROM purchase p
    JOIN player_profile pp USING (device_id)
    WHERE CAST(p.event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(p.event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY 1
), daily AS (
    SELECT
        a.activity_date,
        a.dau,
        COALESCE(r.revenue, 0) AS revenue
    FROM daily_active a
    LEFT JOIN daily_revenue r USING (activity_date)
), periods AS (
    SELECT 'First 30 Days' AS period, *
    FROM daily
    WHERE activity_date BETWEEN DATE '2026-01-01' AND DATE '2026-01-30'
    UNION ALL
    SELECT 'Last 30 Days' AS period, *
    FROM daily
    WHERE activity_date BETWEEN DATE '2026-04-01' AND DATE '2026-04-30'
)
SELECT
    period,
    SUM(dau) AS active_player_days,
    SUM(revenue) AS revenue,
    SUM(revenue) / NULLIF(SUM(dau), 0) AS arpdau
FROM periods
GROUP BY period
ORDER BY CASE period WHEN 'First 30 Days' THEN 1 ELSE 2 END;
