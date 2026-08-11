-- =====================================================================
-- Requêtes KPI — répondent à la question métier : « les ventes ont chuté,
-- pourquoi ? ». Chaque requête cible une sous-question. Périmètre : commandes
-- livrées (delivered) = CA réalisé.
-- =====================================================================

-- Q1 — Évolution du CA et du volume par mois (où est la baisse ?)
SELECT o.purchase_month,
       count(DISTINCT o.order_id)          AS commandes,
       round(sum(i.price), 0)              AS ca,
       -- variation MoM du CA
       round(100.0 * (sum(i.price) - lag(sum(i.price)) OVER (ORDER BY o.purchase_month))
             / nullif(lag(sum(i.price)) OVER (ORDER BY o.purchase_month), 0), 1) AS mom_pct
FROM olist.v_orders o
JOIN olist.v_items i ON i.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.purchase_month IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- Q2 — La baisse vient-elle de la livraison / satisfaction ? (2018)
SELECT o.purchase_month,
       round(avg(o.delivery_days), 1)            AS delai_moyen_j,
       round(100.0 * avg((o.is_late)::int), 1)   AS pct_retard,
       round(avg(r.review_score), 2)             AS note_moyenne
FROM olist.v_orders o
LEFT JOIN olist.v_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.purchase_month >= DATE '2018-01-01'
GROUP BY 1 ORDER BY 1;

-- Q3 — Impact d'un retard sur la note (levier de satisfaction)
SELECT o.is_late,
       count(*)                       AS commandes,
       round(avg(r.review_score), 2)  AS note_moyenne
FROM olist.v_orders o
JOIN olist.v_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.is_late IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- Q4 — Top catégories par CA (où se concentre le chiffre)
SELECT p.category,
       round(sum(i.price), 0)       AS ca,
       count(DISTINCT o.order_id)   AS commandes
FROM olist.v_orders o
JOIN olist.v_items i    ON i.order_id = o.order_id
JOIN olist.v_products p ON p.product_id = i.product_id
WHERE o.order_status = 'delivered'
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- Q5 — Concentration géographique (part de CA par état)
SELECT c.state,
       round(sum(i.price), 0)  AS ca,
       round(100.0 * sum(i.price) / sum(sum(i.price)) OVER (), 1) AS part_pct
FROM olist.v_orders o
JOIN olist.v_items i     ON i.order_id = o.order_id
JOIN olist.v_customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- Q6 — Rétention : part de clients n'ayant commandé qu'une fois
WITH par_client AS (
    SELECT c.customer_unique_id, count(DISTINCT o.order_id) AS n
    FROM olist.v_orders o
    JOIN olist.v_customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT count(*)                                              AS clients_uniques,
       round(100.0 * count(*) FILTER (WHERE n = 1) / count(*), 1) AS pct_one_shot
FROM par_client;

-- Q7 — Panier moyen par mois (valeur par commande)
WITH par_commande AS (
    SELECT o.order_id, o.purchase_month, sum(i.price) AS montant
    FROM olist.v_orders o
    JOIN olist.v_items i ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered' AND o.purchase_month IS NOT NULL
    GROUP BY 1, 2
)
SELECT purchase_month, round(avg(montant), 2) AS panier_moyen
FROM par_commande GROUP BY 1 ORDER BY 1;
