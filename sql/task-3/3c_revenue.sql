WITH players AS (
    SELECT
        device_id,
        CAST(install_date AS DATE) AS install_date,
        acquisition_channel,
        country_tier,
        platform,
        DATE_TRUNC('month', CAST(install_date AS DATE)) AS install_month
    FROM player_profile
    WHERE acquisition_channel IN ('organic','paid_social','paid_video')
      AND CAST(install_date AS DATE) <= DATE '2026-03-31'
),
player_metrics AS (
    SELECT
        p.device_id,
        p.install_date,
        p.acquisition_channel,
        p.country_tier,
        p.platform,
        p.install_month,
        COALESCE(SUM(
            CASE
                WHEN CAST(pu.event_ts AS TIMESTAMP) >= CAST(p.install_date AS TIMESTAMP)
                 AND CAST(pu.event_ts AS TIMESTAMP) < CAST(p.install_date + INTERVAL '30 days' AS TIMESTAMP)
                THEN pu.usd_amount ELSE 0
            END
        ),0) AS revenue_30d
    FROM players p
    LEFT JOIN purchase pu ON pu.device_id = p.device_id
    GROUP BY 1,2,3,4,5,6
)
SELECT * FROM player_metrics;
