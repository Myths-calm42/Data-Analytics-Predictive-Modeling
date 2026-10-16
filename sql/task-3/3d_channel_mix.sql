WITH eligible AS (
    SELECT
        acquisition_channel,
        country_tier,
        DATE_TRUNC('month', CAST(install_date AS DATE)) AS install_month
    FROM player_profile
    WHERE acquisition_channel IN ('organic','paid_social','paid_video')
      AND CAST(install_date AS DATE) >= DATE '2026-01-01'
      AND CAST(install_date AS DATE) <= DATE '2026-03-31'
)
SELECT
    acquisition_channel,
    country_tier,
    install_month,
    COUNT(*) AS players
FROM eligible
GROUP BY 1,2,3
ORDER BY 1,2,3;
