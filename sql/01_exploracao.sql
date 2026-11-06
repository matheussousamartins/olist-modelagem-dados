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

-- P2: chaves de customers
SELECT count(*) AS linhas,
       count(DISTINCT customer_id) AS distintos_customer_id,
       count(DISTINCT customer_unique_id) AS distintos_unique_id
FROM 'data/raw/olist_customers_dataset.csv';

-- P2: chaves de order_items
SELECT count(*) AS linhas,
       count(DISTINCT order_id) AS distintos_order_id,
       count(DISTINCT (order_id, order_item_id)) AS distintos_order_item
FROM 'data/raw/olist_order_items_dataset.csv';

-- P2: chaves de payments
SELECT count(*) AS linhas,
       count(DISTINCT order_id) AS distintos_order_id,
       count(DISTINCT (order_id, payment_sequential)) AS distintos_order_payment
FROM 'data/raw/olist_order_payments_dataset.csv';