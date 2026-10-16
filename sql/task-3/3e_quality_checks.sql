SELECT 'duplicate player_profile device_id' AS check_name,
       COUNT(*) AS issue_count
FROM (
    SELECT device_id FROM player_profile GROUP BY 1 HAVING COUNT(*) > 1
)
UNION ALL
SELECT 'duplicate player_day player-date key', COUNT(*)
FROM (
    SELECT device_id, activity_date FROM player_day
    GROUP BY 1,2 HAVING COUNT(*) > 1
)
UNION ALL
SELECT 'purchase IDs appearing more than once', COUNT(*)
FROM (
    SELECT purchase_id FROM purchase GROUP BY 1 HAVING COUNT(*) > 1
)
UNION ALL
SELECT 'purchases before recorded install', COUNT(*)
FROM purchase pu
JOIN player_profile pp USING(device_id)
WHERE CAST(pu.event_ts AS TIMESTAMP) < CAST(pp.install_date AS TIMESTAMP)
UNION ALL
SELECT 'purchase rows outside assignment window', COUNT(*)
FROM purchase
WHERE CAST(event_ts AS DATE) < DATE '2026-01-01'
   OR CAST(event_ts AS DATE) >= DATE '2026-05-01';
