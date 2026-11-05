-- P1: quantas linhas tem cada arquivo?
SELECT 'orders' as tabela, 
        count(*) as linhas 
FROM 'data/raw/olist_orders_dataset.csv'
UNION ALL
SELECT 'customers', 
        count(*) 
FROM 'data/raw/olist_customers_dataset.csv'
UNION ALL
SELECT 'order_items',
        count(*)
FROM 'data/raw/olist_order_items_dataset.csv'
UNION ALL
SELECT 'payments',
       count(*)
FROM 'data/raw/olist_order_payments_dataset.csv'
UNION ALL
SELECT 'order_reviews',
       count(*)
FROM 'data/raw/olist_order_reviews_dataset.csv'
UNION ALL
SELECT 'products',
       count(*)
FROM 'data/raw/olist_products_dataset.csv'
UNION ALL
SELECT 'sellers',
       count(*)
FROM 'data/raw/olist_sellers_dataset.csv'
UNION ALL
SELECT 'geolocation',
       count(*)
FROM 'data/raw/olist_geolocation_dataset.csv'
UNION ALL
SELECT 'category_translation',
       count(*)
FROM 'data/raw/product_category_name_translation.csv';

-- P2: order_id é único em orders?
-- select count(*) as linhas, 
--         count(distinct order_id) as distintos
-- from 'data/raw/olist_orders_dataset.csv';