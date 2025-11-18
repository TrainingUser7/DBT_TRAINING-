{{ config(materialized="incremental", unique_key="order_id") }}
with
    orders as (
        select
            order_id,
            customer_id,
            store_id,
            order_date,
            order_status,
            order_total,
            discount_amt,
            tax_amt
        from {{ ref("stg_orders") }}
        where order_status = 'COMPLETED'
 
    ),
    order_items as (
        select
            order_id,
            line_num,
            product_sku,
            product_name,
            quantity,
            unit_price,
            extended_price,
            coalesce(discount_amt, 0) as line_discount
        from {{ ref("stg_order_items") }}
    ),
    enriched as (
        select
            o.order_id,
            date_trunc('day', o.order_date)::date as order_date,
            s.region_name,
            o.store_id,
            s.store_name,
            o.customer_id,
            c.loyalty_tier,
            sum(oi.extended_price) as discounts,
            sum(oi.extended_price) - sum(oi.line_discount) as net_sales,
            sum(o.tax_amt) as tax_amt
        from orders o
        left join order_items oi on o.order_id = oi.order_id
        left join {{ ref("stg_stores") }} s on o.store_id = s.store_id
        left join {{ ref("stg_customers") }} c on o.customer_id = c.customer_id
        group by 1, 2, 3, 4, 5, 6, 7
 
    )

select order_id, order_date,region_name,store_id,store_name,
customer_id,loyalty_tier,gross_sales, discounts,net_sales, tax_amt
from enriched

{% if is_incremental() %}

where order_date > (select coalesce(max(order_date),
'1900-01-01') from {{ this }})

{% endif %}