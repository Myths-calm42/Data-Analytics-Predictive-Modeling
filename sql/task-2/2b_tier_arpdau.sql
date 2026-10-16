-- ARPDAU by country tier: first 30 days vs last 30 days
WITH active AS (
    SELECT
        STRPTIME(CAST(pd.activity_date AS VARCHAR), '%Y%m%d')::DATE AS activity_date,
        pd.device_id,
        pp.country_tier
    FROM player_day pd
    JOIN player_profile pp USING (device_id)
    WHERE pd.activity_date BETWEEN 20260101 AND 20260430
), daily_tier AS (
    SELECT
        activity_date,
        country_tier,
        COUNT(DISTINCT device_id) AS dau
    FROM active
    GROUP BY 1, 2
), revenue AS (
    SELECT
        CAST(p.event_ts AS DATE) AS activity_date,
        pp.country_tier,
        SUM(p.usd_amount) AS revenue
    FROM purchase p
    JOIN player_profile pp USING (device_id)
    WHERE CAST(p.event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(p.event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY 1, 2
), daily AS (
    SELECT
        d.activity_date,
        d.country_tier,
        d.dau,
        COALESCE(r.revenue, 0) AS revenue
    FROM daily_tier d
    LEFT JOIN revenue r USING (activity_date, country_tier)
), period_tier AS (
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
    country_tier,
    SUM(dau) AS active_player_days,
    SUM(revenue) AS revenue,
    SUM(revenue) / NULLIF(SUM(dau), 0) AS arpdau,
    SUM(revenue) / NULLIF(SUM(dau), 0) AS arpdau_usd
FROM period_tier
GROUP BY period, country_tier
ORDER BY country_tier, CASE period WHEN 'First 30 Days' THEN 1 ELSE 2 END;
