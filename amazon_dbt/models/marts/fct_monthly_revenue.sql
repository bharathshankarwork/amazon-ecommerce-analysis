-- Monthly revenue trend. Mirrors query #3.

with sales as (
    select * from {{ ref('stg_amazon_sales') }}
)

select
    to_char(purchase_date, 'YYYY-MM')                   as month,
    count(*)                                            as total_orders,
    round(sum(final_price)::numeric, 2)                 as monthly_revenue
from sales
group by month
order by month
