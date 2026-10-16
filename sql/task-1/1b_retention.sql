-- ============================================================
-- TASK 1B — RETENTION COHORT TABLE
-- Cohort = install week.
-- Retention = active on exact life-day D1/D7/D14/D30.
--
-- Recent players are not forced into incomplete milestones:
-- each milestone only includes players whose individual install
-- date is far enough before 2026-04-30 to observe that milestone.
-- ============================================================

WITH installs AS (
    SELECT
        device_id,
        CAST(install_date AS DATE) AS install_date,
        DATE_TRUNC('week', CAST(install_date AS DATE))::DATE AS cohort_week
    FROM player_profile
    WHERE CAST(install_date AS DATE) >= DATE '2026-01-01'
      AND CAST(install_date AS DATE) < DATE '2026-05-01'
),

active_days AS (
    SELECT DISTINCT
        device_id,
        STRPTIME(CAST(activity_date AS VARCHAR), '%Y%m%d')::DATE AS activity_date
    FROM player_day
    WHERE activity_date >= 20260101
      AND activity_date <= 20260430
)

SELECT
    i.cohort_week,

    COUNT(*) AS cohort_players,

    COUNT(*) FILTER (
        WHERE i.install_date + INTERVAL 1 DAY <= DATE '2026-04-30'
    ) AS d1_eligible_players,

    COUNT(*) FILTER (
        WHERE i.install_date + INTERVAL 7 DAY <= DATE '2026-04-30'
    ) AS d7_eligible_players,

    COUNT(*) FILTER (
        WHERE i.install_date + INTERVAL 14 DAY <= DATE '2026-04-30'
    ) AS d14_eligible_players,

    COUNT(*) FILTER (
        WHERE i.install_date + INTERVAL 30 DAY <= DATE '2026-04-30'
    ) AS d30_eligible_players,

    COUNT(a1.device_id) AS d1_retained_players,
    COUNT(a7.device_id) AS d7_retained_players,
    COUNT(a14.device_id) AS d14_retained_players,
    COUNT(a30.device_id) AS d30_retained_players,

    COUNT(a1.device_id) * 1.0 /
        NULLIF(COUNT(*) FILTER (
            WHERE i.install_date + INTERVAL 1 DAY <= DATE '2026-04-30'
        ), 0) AS d1_retention,

    COUNT(a7.device_id) * 1.0 /
        NULLIF(COUNT(*) FILTER (
            WHERE i.install_date + INTERVAL 7 DAY <= DATE '2026-04-30'
        ), 0) AS d7_retention,

    COUNT(a14.device_id) * 1.0 /
        NULLIF(COUNT(*) FILTER (
            WHERE i.install_date + INTERVAL 14 DAY <= DATE '2026-04-30'
        ), 0) AS d14_retention,

    COUNT(a30.device_id) * 1.0 /
        NULLIF(COUNT(*) FILTER (
            WHERE i.install_date + INTERVAL 30 DAY <= DATE '2026-04-30'
        ), 0) AS d30_retention

FROM installs i

LEFT JOIN active_days a1
  ON i.device_id = a1.device_id
 AND a1.activity_date = i.install_date + INTERVAL 1 DAY

LEFT JOIN active_days a7
  ON i.device_id = a7.device_id
 AND a7.activity_date = i.install_date + INTERVAL 7 DAY

LEFT JOIN active_days a14
  ON i.device_id = a14.device_id
 AND a14.activity_date = i.install_date + INTERVAL 14 DAY

LEFT JOIN active_days a30
  ON i.device_id = a30.device_id
 AND a30.activity_date = i.install_date + INTERVAL 30 DAY

GROUP BY i.cohort_week
ORDER BY i.cohort_week;
