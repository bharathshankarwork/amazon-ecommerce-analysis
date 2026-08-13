-- Staging: light type-safety pass over amazon_sales.
-- Source columns: seller_id, seller_rating, final_price, is_returned,
-- category, device, payment_method, shipping_time_days, rating, discount, purchase_date

with source as (
    select * from {{ source('raw', 'amazon_sales') }}
),

renamed as (
    select
        seller_id,
        category,
        device,
        payment_method,
        cast(shipping_time_days as int)      as shipping_time_days,
        cast(rating as numeric)              as rating,
        cast(seller_rating as numeric)       as seller_rating,
        cast(discount as numeric)            as discount,
        cast(final_price as numeric)         as final_price,
        cast(is_returned as boolean)         as is_returned,
        cast(purchase_date as date)          as purchase_date
    from source
    where purchase_date is not null
)

select * from renamed
