-- Return rate by shipping time. Mirrors query #4.

with sales as (
    select * from {{ ref('stg_amazon_sales') }}
)

select
    shipping_time_days,
    count(*)                                            as total_orders,
    sum(case when is_returned then 1 else 0 end)        as total_returns,
    round(sum(case when is_returned then 1 else 0 end) * 100.0 / count(*), 2) as return_rate
from sales
group by shipping_time_days
order by shipping_time_days
