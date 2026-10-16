-- TASK 4 STEP 3 — FEATURES
-- One row per currently-active player × prediction date.
-- All features use information available on or before prediction_date.

WITH activity AS (
    SELECT
        device_id,
        CAST(
            STRPTIME(CAST(activity_date AS VARCHAR), '%Y%m%d')
            AS DATE
        ) AS activity_date,
        player_level,
        session_count,
        playtime_minutes,
        app_version
    FROM player_day
),

prediction_dates AS (
    SELECT prediction_date
    FROM generate_series(
        DATE '2026-02-01',
        DATE '2026-04-16',
        INTERVAL '1 day'
    ) AS t(prediction_date)
),

active_players AS (
    SELECT DISTINCT
        a.device_id,
        d.prediction_date
    FROM prediction_dates d
    JOIN activity a
      ON a.activity_date BETWEEN
         d.prediction_date - INTERVAL '6 days'
         AND d.prediction_date
),

base AS (
    SELECT
        ap.device_id,
        ap.prediction_date,
        p.install_date,
        p.platform,
        p.country,
        p.country_tier,
        p.acquisition_channel,
        DATE_DIFF(
            'day',
            CAST(p.install_date AS DATE),
            ap.prediction_date
        ) AS days_since_install
    FROM active_players ap
    JOIN player_profile p
      ON p.device_id = ap.device_id
),

player_features AS (
    SELECT
        b.device_id,
        b.prediction_date,

        COUNT(DISTINCT CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '6 days'
             AND a.activity_date <= b.prediction_date
            THEN a.activity_date END
        ) AS active_days_7d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '6 days'
             AND a.activity_date <= b.prediction_date
            THEN a.playtime_minutes ELSE 0 END
        ) AS playtime_7d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '6 days'
             AND a.activity_date <= b.prediction_date
            THEN a.session_count ELSE 0 END
        ) AS sessions_7d,

        COUNT(DISTINCT CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '13 days'
             AND a.activity_date <= b.prediction_date
            THEN a.activity_date END
        ) AS active_days_14d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '13 days'
             AND a.activity_date <= b.prediction_date
            THEN a.playtime_minutes ELSE 0 END
        ) AS playtime_14d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '13 days'
             AND a.activity_date <= b.prediction_date
            THEN a.session_count ELSE 0 END
        ) AS sessions_14d,

        COUNT(DISTINCT CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '29 days'
             AND a.activity_date <= b.prediction_date
            THEN a.activity_date END
        ) AS active_days_30d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '29 days'
             AND a.activity_date <= b.prediction_date
            THEN a.playtime_minutes ELSE 0 END
        ) AS playtime_30d,

        SUM(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '29 days'
             AND a.activity_date <= b.prediction_date
            THEN a.session_count ELSE 0 END
        ) AS sessions_30d,

        MAX(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '29 days'
             AND a.activity_date <= b.prediction_date
            THEN a.player_level END
        ) AS max_player_level_30d,

        MIN(CASE
            WHEN a.activity_date >= b.prediction_date - INTERVAL '29 days'
             AND a.activity_date <= b.prediction_date
            THEN a.player_level END
        ) AS min_player_level_30d,

        MAX(a.activity_date) AS last_activity_date,

        MAX_BY(a.player_level, a.activity_date) AS last_player_level,

        MAX_BY(a.app_version, a.activity_date) AS last_app_version

    FROM base b
    LEFT JOIN activity a
      ON a.device_id = b.device_id
     AND a.activity_date <= b.prediction_date
     AND a.activity_date >= b.prediction_date - INTERVAL '29 days'
    GROUP BY
        b.device_id,
        b.prediction_date
),

purchase_features AS (
    SELECT
        b.device_id,
        b.prediction_date,

        COALESCE(SUM(CASE
            WHEN CAST(pu.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '6 days'
             AND CAST(pu.event_ts AS DATE)
                 <= b.prediction_date
            THEN pu.usd_amount ELSE 0 END), 0) AS revenue_7d,

        COUNT(CASE
            WHEN CAST(pu.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '6 days'
             AND CAST(pu.event_ts AS DATE)
                 <= b.prediction_date
            THEN pu.purchase_id END) AS purchase_count_7d,

        COALESCE(SUM(CASE
            WHEN CAST(pu.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '29 days'
             AND CAST(pu.event_ts AS DATE)
                 <= b.prediction_date
            THEN pu.usd_amount ELSE 0 END), 0) AS revenue_30d,

        COUNT(CASE
            WHEN CAST(pu.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '29 days'
             AND CAST(pu.event_ts AS DATE)
                 <= b.prediction_date
            THEN pu.purchase_id END) AS purchase_count_30d,

        MAX(CAST(pu.event_ts AS DATE)) AS last_purchase_date

    FROM base b
    LEFT JOIN purchase pu
      ON pu.device_id = b.device_id
     AND CAST(pu.event_ts AS DATE) <= b.prediction_date
     AND CAST(pu.event_ts AS DATE)
         >= b.prediction_date - INTERVAL '29 days'
    GROUP BY
        b.device_id,
        b.prediction_date
),

currency_features AS (
    SELECT
        b.device_id,
        b.prediction_date,

        COALESCE(SUM(CASE
            WHEN CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) >= b.prediction_date - INTERVAL '6 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) <= b.prediction_date
            THEN cs.currency_value ELSE 0 END), 0) AS currency_spend_7d,

        COUNT(CASE
            WHEN CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) >= b.prediction_date - INTERVAL '6 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) <= b.prediction_date
            THEN 1 END) AS currency_spend_count_7d,

        COALESCE(SUM(CASE
            WHEN CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) >= b.prediction_date - INTERVAL '29 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) <= b.prediction_date
            THEN cs.currency_value ELSE 0 END), 0) AS currency_spend_30d,

        COUNT(CASE
            WHEN CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) >= b.prediction_date - INTERVAL '29 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
            ) <= b.prediction_date
            THEN 1 END) AS currency_spend_count_30d,

        COALESCE(SUM(CASE
            WHEN cs.currency_type = 'PREMIUM'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) >= b.prediction_date - INTERVAL '29 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) <= b.prediction_date
            THEN cs.currency_value ELSE 0 END), 0) AS premium_spend_30d,

        COALESCE(SUM(CASE
            WHEN cs.currency_type = 'SOCIAL'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) >= b.prediction_date - INTERVAL '29 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) <= b.prediction_date
            THEN cs.currency_value ELSE 0 END), 0) AS social_spend_30d,

        COALESCE(SUM(CASE
            WHEN cs.currency_type = 'GRIND'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) >= b.prediction_date - INTERVAL '29 days'
             AND CAST(
                STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
             ) <= b.prediction_date
            THEN cs.currency_value ELSE 0 END), 0) AS grind_spend_30d

    FROM base b
    LEFT JOIN currency_spend cs
      ON cs.device_id = b.device_id
     AND CAST(
            STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
         ) <= b.prediction_date
     AND CAST(
            STRPTIME(cs.event_ts, '%d-%m-%Y %H:%M') AS DATE
         ) >= b.prediction_date - INTERVAL '29 days'
    GROUP BY
        b.device_id,
        b.prediction_date
),

ad_features AS (
    SELECT
        b.device_id,
        b.prediction_date,

        COUNT(CASE
            WHEN av.status = 'started'
             AND CAST(av.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '6 days'
             AND CAST(av.event_ts AS DATE)
                 <= b.prediction_date
            THEN 1 END) AS ads_started_7d,

        COUNT(CASE
            WHEN av.status = 'completed'
             AND CAST(av.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '6 days'
             AND CAST(av.event_ts AS DATE)
                 <= b.prediction_date
            THEN 1 END) AS ads_completed_7d,

        COUNT(CASE
            WHEN av.status = 'started'
             AND CAST(av.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '29 days'
             AND CAST(av.event_ts AS DATE)
                 <= b.prediction_date
            THEN 1 END) AS ads_started_30d,

        COUNT(CASE
            WHEN av.status = 'completed'
             AND CAST(av.event_ts AS DATE)
                 >= b.prediction_date - INTERVAL '29 days'
             AND CAST(av.event_ts AS DATE)
                 <= b.prediction_date
            THEN 1 END) AS ads_completed_30d

    FROM base b
    LEFT JOIN ad_view av
      ON av.device_id = b.device_id
     AND CAST(av.event_ts AS DATE) <= b.prediction_date
     AND CAST(av.event_ts AS DATE)
         >= b.prediction_date - INTERVAL '29 days'
    GROUP BY
        b.device_id,
        b.prediction_date
)

SELECT
    b.*,

    pf.active_days_7d,
    pf.playtime_7d,
    pf.sessions_7d,
    pf.active_days_14d,
    pf.playtime_14d,
    pf.sessions_14d,
    pf.active_days_30d,
    pf.playtime_30d,
    pf.sessions_30d,
    pf.max_player_level_30d,
    pf.min_player_level_30d,
    pf.last_player_level,
    pf.last_activity_date,
    DATE_DIFF(
        'day',
        pf.last_activity_date,
        b.prediction_date
    ) AS days_since_last_play,
    pf.last_app_version,

    (pf.max_player_level_30d - pf.min_player_level_30d)
        AS level_progress_30d,

    pu.revenue_7d,
    pu.purchase_count_7d,
    pu.revenue_30d,
    pu.purchase_count_30d,
    pu.last_purchase_date,

    CASE
        WHEN pu.last_purchase_date IS NULL THEN NULL
        ELSE DATE_DIFF(
            'day',
            pu.last_purchase_date,
            b.prediction_date
        )
    END AS days_since_last_purchase,

    cs.currency_spend_7d,
    cs.currency_spend_count_7d,
    cs.currency_spend_30d,
    cs.currency_spend_count_30d,
    cs.premium_spend_30d,
    cs.social_spend_30d,
    cs.grind_spend_30d,

    av.ads_started_7d,
    av.ads_completed_7d,
    av.ads_started_30d,
    av.ads_completed_30d,

    CASE
        WHEN av.ads_started_7d > 0
        THEN av.ads_completed_7d * 1.0 / av.ads_started_7d
        ELSE 0
    END AS ad_completion_rate_7d,

    CASE
        WHEN av.ads_started_30d > 0
        THEN av.ads_completed_30d * 1.0 / av.ads_started_30d
        ELSE 0
    END AS ad_completion_rate_30d

FROM base b
JOIN player_features pf
  ON pf.device_id = b.device_id
 AND pf.prediction_date = b.prediction_date
JOIN purchase_features pu
  ON pu.device_id = b.device_id
 AND pu.prediction_date = b.prediction_date
JOIN currency_features cs
  ON cs.device_id = b.device_id
 AND cs.prediction_date = b.prediction_date
JOIN ad_features av
  ON av.device_id = b.device_id
 AND av.prediction_date = b.prediction_date
ORDER BY
    b.prediction_date,
    b.device_id;