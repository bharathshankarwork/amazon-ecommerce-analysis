-- Amazon E-Commerce Sales Analysis — pgAdmin queries
-- Table: amazon_sales
-- Columns: seller_id, seller_rating, final_price, is_returned, category,
--          device, payment_method, shipping_time_days, rating, discount, purchase_date

-- 1. Schema / sanity checks
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
SELECT COUNT(*) FROM amazon_sales;
SELECT * FROM amazon_sales LIMIT 5;
SELECT MIN(purchase_date) AS start_date, MAX(purchase_date) AS end_date, COUNT(*) AS row_count
FROM amazon_sales;

-- 2. Revenue and returns by category, device, payment method, rating
SELECT
    category, device, payment_method, shipping_time_days, rating, is_returned,
    COUNT(*) AS order_count,
    ROUND(SUM(final_price)::numeric, 2) AS revenue,
    ROUND(AVG(discount)::numeric, 2) AS avg_discount
FROM amazon_sales
GROUP BY 1, 2, 3, 4, 5, 6;

-- 3. Monthly revenue trend
SELECT
    TO_CHAR(purchase_date::date, 'YYYY-MM') AS month,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_price)::numeric, 2) AS monthly_revenue
FROM amazon_sales
GROUP BY month
ORDER BY month ASC;

-- 4. Return rate by shipping time
SELECT
    shipping_time_days,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_returned = true THEN 1 ELSE 0 END) AS total_returns,
    ROUND(SUM(CASE WHEN is_returned = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate
FROM amazon_sales
GROUP BY shipping_time_days
ORDER BY shipping_time_days ASC;

-- 5. Top sellers by revenue, with rating and return rate (min 10 orders)
SELECT
    seller_id,
    ROUND(AVG(seller_rating)::numeric, 2) AS avg_seller_rating,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_price)::numeric, 2) AS total_revenue,
    ROUND(SUM(CASE WHEN is_returned = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate
FROM amazon_sales
GROUP BY seller_id
HAVING COUNT(*) >= 10
ORDER BY total_revenue DESC
LIMIT 20;

-- 6. Sellers with worst return rates (min 100 orders)
SELECT
    seller_id,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_returned = true THEN 1 ELSE 0 END) AS total_returns,
    ROUND(SUM(CASE WHEN is_returned = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_percentage
FROM amazon_sales
GROUP BY seller_id
HAVING COUNT(*) > 100
ORDER BY return_percentage DESC
LIMIT 10;

-- 7. High-rated sellers (avg seller_rating >= 3.5, min 100 orders) ranked by revenue
SELECT
    seller_id,
    ROUND(AVG(seller_rating)::numeric, 2) AS avg_seller_rating,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(rating)::numeric, 2) AS avg_product_rating
FROM amazon_sales
GROUP BY seller_id
HAVING AVG(seller_rating) >= 3.5 AND COUNT(*) >= 100
ORDER BY total_revenue DESC
LIMIT 10;

-- 8. Highest-volume sellers by rating and revenue (min 500 orders)
SELECT
    seller_id,
    ROUND(AVG(seller_rating)::numeric, 2) AS avg_rating,
    COUNT(*) AS total_sales,
    ROUND(SUM(final_price)::numeric, 2) AS total_revenue
FROM amazon_sales
GROUP BY seller_id
HAVING COUNT(*) > 500
ORDER BY avg_rating DESC, total_revenue DESC
LIMIT 10;

-- Export full cleaned dataset (used to bring the table back into Python/pandas)
-- COPY (SELECT * FROM public.amazon_sales) TO 'C:\Users\bhara\full_dataset.csv' WITH (FORMAT CSV, HEADER);
