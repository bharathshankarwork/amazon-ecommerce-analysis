-- Exploratory queries against raw_orders (post-load, pre-dbt)
-- Adjust column names to match your actual schema.

-- Row count + sanity check
SELECT count(*) FROM raw_orders;

-- Revenue by category (should roughly match dashboard: Electronics ~£6.6bn)
SELECT category, sum(revenue) AS total_revenue
FROM raw_orders
GROUP BY category
ORDER BY total_revenue DESC;

-- Return rate by rating bucket
SELECT round(rating::numeric, 0) AS rating_bucket,
       avg(is_returned::int) AS return_rate
FROM raw_orders
GROUP BY 1
ORDER BY 1;

-- Order split by device/channel
SELECT device_type, count(*) AS orders, count(*) * 100.0 / sum(count(*)) OVER () AS pct
FROM raw_orders
GROUP BY device_type;
