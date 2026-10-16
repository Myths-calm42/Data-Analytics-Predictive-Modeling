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
                WHEN CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) >= p.install_date
                 AND CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) < p.install_date + INTERVAL '7 days'
                THEN d.playtime_minutes ELSE 0
            END
        ),0) AS playtime_7d,
        COALESCE(SUM(
            CASE
                WHEN CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) >= p.install_date
                 AND CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) < p.install_date + INTERVAL '7 days'
                THEN d.session_count ELSE 0
            END
        ),0) AS sessions_7d,
        COUNT(DISTINCT CASE
            WHEN CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) >= p.install_date
             AND CAST(STRPTIME(CAST(d.activity_date AS VARCHAR), '%Y%m%d') AS DATE) < p.install_date + INTERVAL '7 days'
            THEN d.activity_date END
        ) AS active_days_7d
    FROM players p
    LEFT JOIN player_day d ON d.device_id = p.device_id
    GROUP BY 1,2,3,4,5,6
)
SELECT * FROM player_metrics;
