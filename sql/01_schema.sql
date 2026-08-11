-- =====================================================================
-- Projet 01 — Chargement brut du dataset Olist dans PostgreSQL.
-- Tout en TEXT d'abord : on charge le brut tel quel, on nettoie/type ensuite
-- (02_clean.sql). C'est le vrai métier : ne jamais faire confiance à la source.
-- =====================================================================
CREATE SCHEMA IF NOT EXISTS olist;

DROP TABLE IF EXISTS olist.orders CASCADE;
CREATE TABLE olist.orders (
    order_id text, customer_id text, order_status text,
    order_purchase_timestamp text, order_approved_at text,
    order_delivered_carrier_date text, order_delivered_customer_date text,
    order_estimated_delivery_date text
);

DROP TABLE IF EXISTS olist.order_items CASCADE;
CREATE TABLE olist.order_items (
    order_id text, order_item_id text, product_id text, seller_id text,
    shipping_limit_date text, price text, freight_value text
);

DROP TABLE IF EXISTS olist.products CASCADE;
CREATE TABLE olist.products (
    product_id text, product_category_name text, product_name_lenght text,
    product_description_lenght text, product_photos_qty text,
    product_weight_g text, product_length_cm text, product_height_cm text,
    product_width_cm text
);

DROP TABLE IF EXISTS olist.reviews CASCADE;
CREATE TABLE olist.reviews (
    review_id text, order_id text, review_score text, review_comment_title text,
    review_comment_message text, review_creation_date text, review_answer_timestamp text
);

DROP TABLE IF EXISTS olist.payments CASCADE;
CREATE TABLE olist.payments (
    order_id text, payment_sequential text, payment_type text,
    payment_installments text, payment_value text
);

DROP TABLE IF EXISTS olist.customers CASCADE;
CREATE TABLE olist.customers (
    customer_id text, customer_unique_id text, customer_zip_code_prefix text,
    customer_city text, customer_state text
);

DROP TABLE IF EXISTS olist.category_translation CASCADE;
CREATE TABLE olist.category_translation (
    product_category_name text, product_category_name_english text
);
