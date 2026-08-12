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

-- state = code (SP) ; state_name = nom complet (São Paulo) pour la carte/lisibilité.
CREATE OR REPLACE VIEW olist.bi_dim_customer AS
SELECT customer_id AS customer_key, customer_unique_id, state, city,
  CASE state
    WHEN 'AC' THEN 'Acre' WHEN 'AL' THEN 'Alagoas' WHEN 'AM' THEN 'Amazonas'
    WHEN 'AP' THEN 'Amapá' WHEN 'BA' THEN 'Bahia' WHEN 'CE' THEN 'Ceará'
    WHEN 'DF' THEN 'Distrito Federal' WHEN 'ES' THEN 'Espírito Santo'
    WHEN 'GO' THEN 'Goiás' WHEN 'MA' THEN 'Maranhão' WHEN 'MG' THEN 'Minas Gerais'
    WHEN 'MS' THEN 'Mato Grosso do Sul' WHEN 'MT' THEN 'Mato Grosso'
    WHEN 'PA' THEN 'Pará' WHEN 'PB' THEN 'Paraíba' WHEN 'PE' THEN 'Pernambuco'
    WHEN 'PI' THEN 'Piauí' WHEN 'PR' THEN 'Paraná' WHEN 'RJ' THEN 'Rio de Janeiro'
    WHEN 'RN' THEN 'Rio Grande do Norte' WHEN 'RO' THEN 'Rondônia'
    WHEN 'RR' THEN 'Roraima' WHEN 'RS' THEN 'Rio Grande do Sul'
    WHEN 'SC' THEN 'Santa Catarina' WHEN 'SE' THEN 'Sergipe'
    WHEN 'SP' THEN 'São Paulo' WHEN 'TO' THEN 'Tocantins'
    ELSE state END AS state_name
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
