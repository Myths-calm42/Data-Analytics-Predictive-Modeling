-- ============================================================
-- TASK 1D — REWARDED ADS
-- Primary definition:
-- "ad-watching player-day" = a player-day with >=1 completed ad.
-- A player-day hits the cap if its maximum recorded ad_daily_count
-- is >= the recorded ad_daily_cap.
-- ============================================================

-- QUERY: 1. Cap hit rate by cap value
WITH completed_ads AS (
    SELECT
        device_id,
        CAST(event_ts AS DATE) AS activity_date,
        ad_daily_count,
        ad_daily_cap
    FROM ad_view
    WHERE status = 'completed'
      AND CAST(event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(event_ts AS DATE) < DATE '2026-05-01'
),
player_days AS (
    SELECT
        device_id,
        activity_date,
        MAX(ad_daily_count) AS max_ad_count,
        MAX(ad_daily_cap) AS ad_daily_cap
    FROM completed_ads
    GROUP BY device_id, activity_date
)
SELECT
    ad_daily_cap,
    COUNT(*) AS ad_watching_player_days,
    SUM(
        CASE WHEN max_ad_count >= ad_daily_cap THEN 1 ELSE 0 END
    ) AS cap_hit_player_days,
    SUM(
        CASE WHEN max_ad_count >= ad_daily_cap THEN 1 ELSE 0 END
    ) * 1.0 / COUNT(*) AS cap_hit_share
FROM player_days
GROUP BY ad_daily_cap
ORDER BY ad_daily_cap;

-- QUERY: 2. Daily ad views
WITH calendar AS (
    SELECT CAST(d AS DATE) AS activity_date
    FROM generate_series(
        DATE '2026-01-01',
        DATE '2026-04-30',
        INTERVAL 1 DAY
    ) t(d)
),
daily_ads AS (
    SELECT
        CAST(event_ts AS DATE) AS activity_date,
        COUNT(*) AS total_ad_events,
        COUNT(*) FILTER (WHERE status = 'completed') AS completed_ad_views,
        COUNT(*) FILTER (WHERE status = 'started') AS started_events,
        COUNT(*) FILTER (WHERE status = 'abandoned') AS abandoned_events
    FROM ad_view
    WHERE CAST(event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY 1
)
SELECT
    c.activity_date,
    COALESCE(a.total_ad_events, 0) AS total_ad_events,
    COALESCE(a.completed_ad_views, 0) AS completed_ad_views,
    COALESCE(a.started_events, 0) AS started_events,
    COALESCE(a.abandoned_events, 0) AS abandoned_events
FROM calendar c
LEFT JOIN daily_ads a
  ON c.activity_date = a.activity_date
ORDER BY c.activity_date;
