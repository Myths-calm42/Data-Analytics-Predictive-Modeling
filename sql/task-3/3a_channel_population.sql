WITH eligible AS (
    SELECT
        device_id,
        CAST(install_date AS DATE) AS install_date,
        acquisition_channel,
        country_tier,
        platform
    FROM player_profile
    WHERE acquisition_channel IN ('organic','paid_social','paid_video')
      AND CAST(install_date AS DATE) <= DATE '2026-03-31'
)
SELECT
    acquisition_channel,
    COUNT(*) AS players
FROM eligible
GROUP BY 1
ORDER BY 1;
