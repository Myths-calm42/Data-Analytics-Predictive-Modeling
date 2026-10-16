-- ============================================================
-- TASK 1C — SPENDER BEHAVIOUR
-- This file has three query blocks.
-- Run each block separately in the SQL editor if desired.
-- ============================================================

-- QUERY: 1. Revenue concentration among PAYING PLAYERS
WITH payer_revenue AS (
    SELECT
        device_id,
        SUM(usd_amount) AS total_revenue
    FROM purchase
    WHERE CAST(event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY device_id
),
ranked AS (
    SELECT
        device_id,
        total_revenue,
        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC, device_id
        ) AS revenue_rank,
        COUNT(*) OVER () AS payer_count,
        SUM(total_revenue) OVER () AS total_payer_revenue
    FROM payer_revenue
)
SELECT
    'Top 1%' AS segment,
    SUM(CASE
        WHEN revenue_rank <= CEIL(payer_count * 0.01)
        THEN total_revenue ELSE 0 END
    ) / MAX(total_payer_revenue) AS revenue_share
FROM ranked
UNION ALL
SELECT
    'Top 10%',
    SUM(CASE
        WHEN revenue_rank <= CEIL(payer_count * 0.10)
        THEN total_revenue ELSE 0 END
    ) / MAX(total_payer_revenue)
FROM ranked
UNION ALL
SELECT
    'Top 50%',
    SUM(CASE
        WHEN revenue_rank <= CEIL(payer_count * 0.50)
        THEN total_revenue ELSE 0 END
    ) / MAX(total_payer_revenue)
FROM ranked
ORDER BY segment;

-- QUERY: 2. Time to first purchase
WITH first_purchase AS (
    SELECT
        device_id,
        MIN(CAST(event_ts AS DATE)) AS first_purchase_date
    FROM purchase
    WHERE CAST(event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(event_ts AS DATE) < DATE '2026-05-01'
    GROUP BY device_id
)
SELECT
    pp.device_id,
    CAST(pp.install_date AS DATE) AS install_date,
    fp.first_purchase_date,
    DATE_DIFF(
        'day',
        CAST(pp.install_date AS DATE),
        fp.first_purchase_date
    ) AS days_to_first_purchase,
    CASE
        WHEN fp.first_purchase_date IS NULL THEN 'Never purchased'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) < 0
            THEN 'Invalid: purchase before install'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) = 0
            THEN 'Same day'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) BETWEEN 1 AND 3
            THEN '1-3 days'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) BETWEEN 4 AND 7
            THEN '4-7 days'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) BETWEEN 8 AND 14
            THEN '8-14 days'
        WHEN DATE_DIFF('day', CAST(pp.install_date AS DATE), fp.first_purchase_date) BETWEEN 15 AND 30
            THEN '15-30 days'
        ELSE '31+ days'
    END AS purchase_timing_bucket
FROM player_profile pp
LEFT JOIN first_purchase fp
  ON pp.device_id = fp.device_id
ORDER BY pp.device_id;

-- QUERY: 3. Repeat purchase gap
WITH ordered_purchases AS (
    SELECT
        device_id,
        event_ts,
        LAG(event_ts) OVER (
            PARTITION BY device_id
            ORDER BY event_ts
        ) AS previous_purchase_ts
    FROM purchase
    WHERE CAST(event_ts AS DATE) >= DATE '2026-01-01'
      AND CAST(event_ts AS DATE) < DATE '2026-05-01'
)
SELECT
    device_id,
    event_ts,
    previous_purchase_ts,
    DATE_DIFF('second', previous_purchase_ts, event_ts) / 86400.0 AS gap_days
FROM ordered_purchases
WHERE previous_purchase_ts IS NOT NULL
ORDER BY device_id, event_ts;
