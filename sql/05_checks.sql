-- =====================================================================
-- Contrôles rejoués en CI : les chiffres de docs/insights.md doivent sortir
-- des requêtes. Une exception = un constat du README qui ne tient plus.
-- =====================================================================
DO $$
DECLARE
    one_shot numeric; part_sp numeric; orphelins int;
BEGIN
    -- « 97 % des clients n'ont commandé qu'une seule fois »
    SELECT round(100.0 * count(*) FILTER (WHERE n = 1) / count(*), 1) INTO one_shot
    FROM (SELECT c.customer_unique_id, count(DISTINCT o.order_id) AS n
          FROM olist.v_orders o JOIN olist.v_customers c USING (customer_id)
          WHERE o.order_status = 'delivered' GROUP BY 1) t;
    IF one_shot NOT BETWEEN 96.5 AND 97.5 THEN RAISE EXCEPTION 'one-shot = % %%, attendu ~97', one_shot; END IF;

    -- « São Paulo = 38 % du CA »
    SELECT round(100.0 * sum(i.price) FILTER (WHERE c.state = 'SP') / sum(i.price), 1) INTO part_sp
    FROM olist.v_orders o JOIN olist.v_items i USING (order_id) JOIN olist.v_customers c USING (customer_id)
    WHERE o.order_status = 'delivered';
    IF part_sp NOT BETWEEN 37.5 AND 38.5 THEN RAISE EXCEPTION 'part SP = % %%, attendu ~38', part_sp; END IF;

    -- étoile Power BI : chaque ligne de fait retrouve son produit, son client et sa date
    SELECT count(*) INTO orphelins FROM olist.bi_fct_sales f
    WHERE NOT EXISTS (SELECT 1 FROM olist.bi_dim_product p WHERE p.product_key = f.product_key)
       OR NOT EXISTS (SELECT 1 FROM olist.bi_dim_customer c WHERE c.customer_key = f.customer_key)
       OR NOT EXISTS (SELECT 1 FROM olist.bi_dim_date d WHERE d.date_key = f.date_key);
    IF orphelins > 0 THEN RAISE EXCEPTION '% lignes de bi_fct_sales sans dimension', orphelins; END IF;

    RAISE NOTICE 'OK : one-shot % %%, SP % %%, 0 orphelin', one_shot, part_sp;
END $$;
