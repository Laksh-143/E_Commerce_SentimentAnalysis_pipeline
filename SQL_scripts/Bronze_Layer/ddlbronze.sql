/*
-------------------------------------
DDL scripts : Creating Bronze Tables
-------------------------------------
Script Purpose:
    This script creates tables in the 'store' schema dropping tables 
    if they already exists.
    Run this script to re_define the DDL structure of the 'store' tables.
------------------------------------
*/

IF OBJECT_ID('store.olist_customers_data' , 'U') IS NOT NULL
       DROP TABLE store.olist_customers_data;


CREATE TABLE store.olist_customers_data(
	customer_id NVARCHAR(50),
	customer_unique_id NVARCHAR(50),
	customer_zip_code_prefix NVARCHAR(10),
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(50)
);

 IF OBJECT_ID('store.olist_geolocation' , 'U') IS NOT NULL
       DROP TABLE store.olist_geolocation;

CREATE TABLE store.olist_geolocation(
	geolocation_zip_code_prefix NVARCHAR(10),
	geolocation_lat NVARCHAR(50),
	geolocation_lng NVARCHAR(50),
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(50)
);

 IF OBJECT_ID('store.olist_orders_items' , 'U') IS NOT NULL
       DROP TABLE store.olist_orders_items;

CREATE TABLE store.olist_orders_items(
	order_id NVARCHAR(50),
	order_item_id INT,
	product_id NVARCHAR(50),
	seller_id NVARCHAR(50),
	shipping_limit_date NVARCHAR(30),
	price NVARCHAR(15),
	freight_value NVARCHAR(15)
);

 IF OBJECT_ID('store.olist_orders_payments' , 'U') IS NOT NULL
       DROP TABLE store.olist_orders_payments;

CREATE TABLE store.olist_orders_payments(
	order_id NVARCHAR(50),
	payment_sequential INT,
	payment_type NVARCHAR(25),
	payment_installments INT,
	payment_value NVARCHAR(15)
);

 IF OBJECT_ID('store.olist_orders' , 'U') IS NOT NULL
       DROP TABLE store.olist_orders;

CREATE TABLE store.olist_orders(
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_status NVARCHAR(15),
	order_purchase_timestamp NVARCHAR(30),
	order_approved_at NVARCHAR(30),
	order_delivered_carrier_date NVARCHAR(30),
	order_delivered_customer_date NVARCHAR(30),
	order_estimated_delivery_date NVARCHAR(30)
);

 IF OBJECT_ID('store.olist_products' , 'U') IS NOT NULL
       DROP TABLE store.olist_products;

CREATE TABLE store.olist_products(
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(50),
	product_name_length NVARCHAR(25),
	product_description_length NVARCHAR(25),
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

 IF OBJECT_ID('store.olist_sellers' , 'U') IS NOT NULL
       DROP TABLE store.olist_sellers;

CREATE TABLE store.olist_sellers(
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(10),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(50)
);

 IF OBJECT_ID('store.olist_product_category_name_translation' , 'U') IS NOT NULL
       DROP TABLE store.olist_product_category_name_translation;

CREATE TABLE store.olist_product_category_name_translation(
	product_category_name NVARCHAR(50),
	product_category_name_english NVARCHAR(50)
);

 IF OBJECT_ID('store.olist_orders_reviews' , 'U') IS NOT NULL
       DROP TABLE store.olist_orders_reviews;

CREATE TABLE store.olist_orders_reviews(
	review_id NVARCHAR(50),
	order_id NVARCHAR(50),
	review_score INT,
	review_comment_title NVARCHAR(100),
	review_comment_message NVARCHAR(500),
	review_creation_date NVARCHAR(30),
	review_answer_timestamp NVARCHAR(30)
);

