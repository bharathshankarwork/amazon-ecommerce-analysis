-- Seller-level revenue, rating and return rate. Mirrors the seller
-- leaderboard queries (#5-#8) in sql/sql_queries.sql.

with sales as (
    select * from {{ ref('stg_amazon_sales') }}
)

select
    seller_id,
    round(avg(seller_rating)::numeric, 2)               as avg_seller_rating,
    round(avg(rating)::numeric, 2)                      as avg_product_rating,
    count(*)                                            as total_orders,
    round(sum(final_price)::numeric, 2)                 as total_revenue,
    round(sum(case when is_returned then 1 else 0 end) * 100.0 / count(*), 2) as return_rate
from sales
group by seller_id
having count(*) >= 10
