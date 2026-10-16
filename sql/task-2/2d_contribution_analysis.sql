-- Decompose overall ARPDAU change into mix and within-tier effects
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
), period_tier AS (
    SELECT
        'First 30 Days' AS period,
        d.country_tier,
        SUM(d.dau) AS dau,
        SUM(COALESCE(r.revenue, 0)) AS revenue
    FROM daily_tier d
    LEFT JOIN revenue r USING (activity_date, country_tier)
    WHERE d.activity_date BETWEEN DATE '2026-01-01' AND DATE '2026-01-30'
    GROUP BY d.country_tier
    UNION ALL
    SELECT
        'Last 30 Days' AS period,
        d.country_tier,
        SUM(d.dau) AS dau,
        SUM(COALESCE(r.revenue, 0)) AS revenue
    FROM daily_tier d
    LEFT JOIN revenue r USING (activity_date, country_tier)
    WHERE d.activity_date BETWEEN DATE '2026-04-01' AND DATE '2026-04-30'
    GROUP BY d.country_tier
), metrics AS (
    SELECT
        period,
        country_tier,
        dau,
        revenue,
        dau * 1.0 / SUM(dau) OVER (PARTITION BY period) AS mix,
        revenue / NULLIF(dau, 0) AS arpdau
    FROM period_tier
), paired AS (
    SELECT
        country_tier,
        MAX(CASE WHEN period = 'First 30 Days' THEN mix END) AS first_mix,
        MAX(CASE WHEN period = 'Last 30 Days' THEN mix END) AS last_mix,
        MAX(CASE WHEN period = 'First 30 Days' THEN arpdau END) AS first_arpdau,
        MAX(CASE WHEN period = 'Last 30 Days' THEN arpdau END) AS last_arpdau
    FROM metrics
    GROUP BY country_tier
), totals AS (
    SELECT
        SUM(first_mix * first_arpdau) AS first_arpdau,
        SUM(last_mix * last_arpdau) AS last_arpdau,
        SUM(last_mix * first_arpdau) AS counterfactual_last_mix_at_first_tier_rate
    FROM paired
)
SELECT
    first_arpdau,
    last_arpdau,
    last_arpdau - first_arpdau AS total_change,
    counterfactual_last_mix_at_first_tier_rate - first_arpdau AS mix_effect,
    last_arpdau - counterfactual_last_mix_at_first_tier_rate AS within_tier_effect,
    CASE
        WHEN ABS(last_arpdau - first_arpdau) > 0
        THEN (counterfactual_last_mix_at_first_tier_rate - first_arpdau)
             / (last_arpdau - first_arpdau)
    END AS share_of_total_change_from_mix
FROM totals;
