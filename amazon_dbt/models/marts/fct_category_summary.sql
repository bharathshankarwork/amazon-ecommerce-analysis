-- Revenue, returns and discount by category/device/payment/rating.
-- Mirrors query #2 in sql/sql_queries.sql and the dashboard's category panel.

with sales as (
    select * from {{ ref('stg_amazon_sales') }}
)

select
    category,
    device,
    payment_method,
    rating,
    count(*)                                            as order_count,
    round(sum(final_price)::numeric, 2)                 as revenue,
    round(avg(discount)::numeric, 2)                     as avg_discount,
    round(sum(case when is_returned then 1 else 0 end) * 100.0 / count(*), 2) as return_rate
from sales
group by 1, 2, 3, 4
