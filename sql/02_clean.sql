-- =====================================================================
-- Nettoyage & typage : on transforme le brut TEXT en vues analytiques typées.
--   - chaînes vides -> NULL (NULLIF) avant cast
--   - horodatages -> timestamp ; montants -> numeric ; note -> int
--   - catégories traduites en anglais (lisible)
--   - délais de livraison calculés (métier)
-- =====================================================================

-- Commandes typées + métriques de livraison
CREATE OR REPLACE VIEW olist.v_orders AS
SELECT
    order_id, customer_id, order_status,
    NULLIF(order_purchase_timestamp, '')::timestamp        AS purchased_at,
    NULLIF(order_delivered_customer_date, '')::timestamp   AS delivered_at,
    NULLIF(order_estimated_delivery_date, '')::timestamp    AS estimated_at,
    date_trunc('month', NULLIF(order_purchase_timestamp, '')::timestamp)::date AS purchase_month,
    -- délai réel de livraison (jours)
    EXTRACT(day FROM NULLIF(order_delivered_customer_date, '')::timestamp
                   - NULLIF(order_purchase_timestamp, '')::timestamp)::int      AS delivery_days,
    -- retard vs date estimée (>0 = en retard)
    EXTRACT(day FROM NULLIF(order_delivered_customer_date, '')::timestamp
                   - NULLIF(order_estimated_delivery_date, '')::timestamp)::int  AS delay_days,
    (NULLIF(order_delivered_customer_date, '')::timestamp
       > NULLIF(order_estimated_delivery_date, '')::timestamp)                   AS is_late
FROM olist.orders;

-- Lignes d'articles typées
CREATE OR REPLACE VIEW olist.v_items AS
SELECT order_id, product_id, seller_id,
       price::numeric        AS price,
       freight_value::numeric AS freight
FROM olist.order_items;

-- Produits avec catégorie traduite (fallback si manquante)
CREATE OR REPLACE VIEW olist.v_products AS
SELECT p.product_id,
       COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
FROM olist.products p
LEFT JOIN olist.category_translation t
       ON t.product_category_name = p.product_category_name;

-- Clients (géographie)
CREATE OR REPLACE VIEW olist.v_customers AS
SELECT customer_id, customer_unique_id, customer_state AS state, customer_city AS city
FROM olist.customers;

-- Un score d'avis moyen par commande (des commandes ont plusieurs avis)
CREATE OR REPLACE VIEW olist.v_reviews AS
SELECT order_id, avg(review_score::numeric) AS review_score
FROM olist.reviews
WHERE NULLIF(review_score, '') IS NOT NULL
GROUP BY order_id;
