-- ============================================================
-- TASK 1A — DAILY HEALTH
-- Output:
-- date, platform, DAU, gross revenue, ARPDAU,
-- paying players, daily purchase rate
-- ============================================================

WITH daily_active AS (
    SELECT
        STRPTIME(CAST(pd.activity_date AS VARCHAR), '%Y%m%d')::DATE AS activity_date,
        pp.platform,
        COUNT(DISTINCT pd.device_id) AS dau
    FROM player_day pd
    JOIN player_profile pp
      ON pd.device_id = pp.device_id
    WHERE pd.activity_date >= 20260101
      AND pd.activity_date <= 20260430
    GROUP BY 1, 2
),

daily_revenue AS (
    SELECT
        CAST(p.event_ts AS DATE) AS activity_date,
        pp.platform,
        SUM(p.usd_amount) AS gross_revenue,
        COUNT(DISTINCT p.device_id) AS paying_players
    FROM purchase p
    JOIN player_profile pp
      ON p.device_id = pp.device_id
    WHERE CAST(p.event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(p.event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY 1, 2
)

SELECT
    a.activity_date,
    a.platform,
    a.dau,
    COALESCE(r.gross_revenue, 0) AS gross_revenue,
    COALESCE(r.gross_revenue, 0) / NULLIF(a.dau, 0) AS arpdau,
    COALESCE(r.paying_players, 0) AS paying_players,
    COALESCE(r.paying_players, 0) * 1.0 / NULLIF(a.dau, 0) AS purchase_rate
FROM daily_active a
LEFT JOIN daily_revenue r
  ON a.activity_date = r.activity_date
 AND a.platform = r.platform
ORDER BY a.activity_date, a.platform;
