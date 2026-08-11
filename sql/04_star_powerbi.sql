-- =====================================================================
-- Modèle en étoile Olist pour Power BI (vues bi_*).
-- Grain des faits = une ligne d'article. Dimensions autour.
-- Périmètre : commandes livrées (CA réalisé).
-- =====================================================================

-- Dimension commande (grain : commande) — porte les métriques niveau commande
CREATE OR REPLACE VIEW olist.bi_dim_orders AS
SELECT o.order_id,
       o.order_status                              AS status,
       o.purchase_month,
       o.delivery_days,
       o.delay_days,
       o.is_late,
       r.review_score
FROM olist.v_orders o
LEFT JOIN olist.v_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered';

CREATE OR REPLACE VIEW olist.bi_dim_product AS
SELECT DISTINCT product_id AS product_key, category
FROM olist.v_products;

CREATE OR REPLACE VIEW olist.bi_dim_customer AS
SELECT customer_id AS customer_key, customer_unique_id, state, city
FROM olist.v_customers;

CREATE OR REPLACE VIEW olist.bi_dim_date AS
WITH bornes AS (
    SELECT min(purchased_at)::date d0, max(purchased_at)::date d1
    FROM olist.v_orders WHERE order_status = 'delivered'
),
jours AS (SELECT generate_series(d0, d1, interval '1 day')::date d FROM bornes)
SELECT to_char(d, 'YYYYMMDD')::int AS date_key, d AS date,
       extract(year from d)::int   AS annee,
       extract(quarter from d)::int AS trimestre,
       extract(month from d)::int  AS mois_num,
       to_char(d, 'YYYY-MM')       AS annee_mois
FROM jours;

-- Table de faits : une ligne d'article d'une commande livrée
CREATE OR REPLACE VIEW olist.bi_fct_sales AS
SELECT i.order_id,
       i.product_id                        AS product_key,
       o.customer_id                       AS customer_key,
       to_char(o.purchased_at, 'YYYYMMDD')::int AS date_key,
       i.price,
       i.freight
FROM olist.v_items i
JOIN olist.v_orders o ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';
