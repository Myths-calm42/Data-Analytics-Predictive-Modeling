-- Change in country-tier active-player mix
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
), period_tier AS (
    SELECT 'First 30 Days' AS period, country_tier, SUM(dau) AS active_player_days
    FROM daily_tier
    WHERE activity_date BETWEEN DATE '2026-01-01' AND DATE '2026-01-30'
    GROUP BY country_tier
    UNION ALL
    SELECT 'Last 30 Days' AS period, country_tier, SUM(dau) AS active_player_days
    FROM daily_tier
    WHERE activity_date BETWEEN DATE '2026-04-01' AND DATE '2026-04-30'
    GROUP BY country_tier
), mix AS (
    SELECT
        period,
        country_tier,
        active_player_days,
        active_player_days * 1.0
            / SUM(active_player_days) OVER (PARTITION BY period) AS dau_mix
    FROM period_tier
)
SELECT
    country_tier,
    MAX(CASE WHEN period = 'First 30 Days' THEN active_player_days END) AS first_active_player_days,
    MAX(CASE WHEN period = 'Last 30 Days' THEN active_player_days END) AS last_active_player_days,
    MAX(CASE WHEN period = 'First 30 Days' THEN dau_mix END) AS first_dau_mix,
    MAX(CASE WHEN period = 'Last 30 Days' THEN dau_mix END) AS last_dau_mix,
    MAX(CASE WHEN period = 'Last 30 Days' THEN dau_mix END)
      - MAX(CASE WHEN period = 'First 30 Days' THEN dau_mix END) AS mix_change
FROM mix
GROUP BY country_tier
ORDER BY country_tier;
