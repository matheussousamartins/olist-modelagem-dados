-- Atalhos para os arquivos
CREATE VIEW orders               AS SELECT * FROM 'data/raw/olist_orders_dataset.csv';
CREATE VIEW customers            AS SELECT * FROM 'data/raw/olist_customers_dataset.csv';
CREATE VIEW order_items          AS SELECT * FROM 'data/raw/olist_order_items_dataset.csv';
CREATE VIEW payments             AS SELECT * FROM 'data/raw/olist_order_payments_dataset.csv';
CREATE VIEW reviews              AS SELECT * FROM 'data/raw/olist_order_reviews_dataset.csv';
CREATE VIEW products             AS SELECT * FROM 'data/raw/olist_products_dataset.csv';
CREATE VIEW sellers              AS SELECT * FROM 'data/raw/olist_sellers_dataset.csv';
CREATE VIEW geolocation          AS SELECT * FROM 'data/raw/olist_geolocation_dataset.csv';
CREATE VIEW category_translation AS SELECT * FROM 'data/raw/product_category_name_translation.csv';

-- P1: quantas linhas tem cada arquivo?
SELECT 'orders' AS tabela,
        count(*) AS linhas
FROM orders
UNION ALL
SELECT 'customers',
        count(*)
FROM customers
UNION ALL
SELECT 'order_items',
        count(*)
FROM order_items
UNION ALL
SELECT 'payments',
       count(*)
FROM payments
UNION ALL
SELECT 'order_reviews',
       count(*)
FROM reviews
UNION ALL
SELECT 'products',
       count(*)
FROM products
UNION ALL
SELECT 'sellers',
       count(*)
FROM sellers
UNION ALL
SELECT 'geolocation',
       count(*)
FROM geolocation
UNION ALL
SELECT 'category_translation',
       count(*)
FROM category_translation;

-- P2: chaves de customers
SELECT count(*) AS linhas,
       count(DISTINCT customer_id) AS distintos_customer_id,
       count(DISTINCT customer_unique_id) AS distintos_unique_id
FROM customers;

-- P2: chaves de order_items
SELECT count(*) AS linhas,
       count(DISTINCT order_id) AS distintos_order_id,
       count(DISTINCT (order_id, order_item_id)) AS distintos_order_item
FROM order_items;

-- P2: chaves de payments
SELECT count(*) AS linhas,
       count(DISTINCT order_id) AS distintos_order_id,
       count(DISTINCT (order_id, payment_sequential)) AS distintos_order_payment
FROM payments;

-- P2: chaves de order_reviews
SELECT count(*) AS linhas,
       count(DISTINCT review_id) AS distintos_review_id,
       count(DISTINCT order_id) AS distintos_order_id,
       count(DISTINCT (review_id, order_id)) AS distintos_review_order
FROM reviews;

-- P2: chaves de products
SELECT count(*) AS linhas,
       count(DISTINCT product_id) AS distintos_product_id
FROM products;

-- P2: chaves de sellers
SELECT count(*) AS linhas,
       count(DISTINCT seller_id) AS distintos_seller_id
FROM sellers;

-- P2: chaves de geolocation
SELECT count(*) AS linhas,
       count(DISTINCT geolocation_zip_code_prefix) AS distintos_cep,
       round(count(*) / count(DISTINCT geolocation_zip_code_prefix), 1) AS linhas_por_cep
FROM geolocation;

-- P2b: review_ids que aparecem em mais de uma linha
SELECT review_id, count(*) AS qtd_linhas
FROM reviews
GROUP BY review_id
HAVING count(*) > 1
ORDER BY qtd_linhas DESC, review_id
LIMIT 5;

-- P2c: detalhe dos review_ids repetidos, com o cliente de cada pedido
WITH repetidos AS (
    SELECT review_id
    FROM reviews
    GROUP BY review_id
    HAVING count(*) > 1
    ORDER BY review_id
    LIMIT 3
)
SELECT r.review_id,
       r.order_id,
       c.customer_unique_id,
       r.review_score,
       r.review_creation_date,
       left(r.review_comment_message, 40) AS comentario
FROM reviews r
JOIN repetidos   USING (review_id)
JOIN orders o    USING (order_id)
JOIN customers c USING (customer_id)
ORDER BY r.review_id, r.order_id;

-- P2d: pedidos com mais de uma avaliação
WITH varias AS (
    SELECT order_id
    FROM reviews
    GROUP BY order_id
    HAVING count(*) > 1
    ORDER BY order_id
    LIMIT 3
)
SELECT r.order_id,
       r.review_id,
       r.review_score,
       r.review_creation_date,
       r.review_answer_timestamp,
       left(r.review_comment_message, 40) AS comentario
FROM reviews r
JOIN varias USING (order_id)
ORDER BY r.order_id, r.review_answer_timestamp;

-- P2e: como são as linhas de um mesmo CEP?
SELECT geolocation_city,
       geolocation_state,
       count(*) AS linhas,
       min(geolocation_lat) AS lat_min,
       max(geolocation_lat) AS lat_max
FROM geolocation
WHERE geolocation_zip_code_prefix = '01001'
GROUP BY ALL;

-- P2f: quantos CEPs têm mais de uma grafia de cidade?
SELECT count(*) AS ceps_com_varias_grafias
FROM (
    SELECT geolocation_zip_code_prefix
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix
    HAVING count(DISTINCT geolocation_city) > 1
);

-- P2g: quantas coordenadas caem fora do Brasil?
SELECT count(*) AS pontos_fora_do_brasil
FROM geolocation
WHERE NOT (geolocation_lat BETWEEN -33.75 AND 5.27
       AND geolocation_lng BETWEEN -73.99 AND -34.79);

-- P2h: grafias de São Paulo na geolocalização
SELECT geolocation_city, count(*) AS linhas
FROM geolocation
WHERE geolocation_city ILIKE 's%o paulo' OR geolocation_city = 'sp'
GROUP BY 1
ORDER BY 2 DESC;