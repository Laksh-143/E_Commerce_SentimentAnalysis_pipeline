/*
-------------------------------------
DDL scripts : Creating Silver Tables
-------------------------------------
Script Purpose:
    This script creates tables in the 'clean' schema dropping tables 
    if they already exists.
    Run this script to re_define the DDL structure of the 'clean' tables.
------------------------------------
*/

-- Table 1. Customers
IF OBJECT_ID('clean.customers', 'U') IS NOT NULL DROP TABLE clean.customers;
CREATE TABLE clean.customers (
    customer_id NVARCHAR(50),
    customer_unique_id NVARCHAR(50),
    customer_zip_code INT,
    customer_city NVARCHAR(100),
    customer_state CHAR(2)
);

-- Table 2: Geolocation
IF OBJECT_ID('clean.geolocation', 'U') IS NOT NULL DROP TABLE clean.geolocation;
CREATE TABLE clean.geolocation (
    zip_code INT,
    lat DECIMAL(18,15),
    lng DECIMAL(18,15),
    city NVARCHAR(100),
    state CHAR(2)
);

-- Table 3: Reviews
IF OBJECT_ID('clean.reviews', 'U') IS NOT NULL DROP TABLE clean.reviews;
CREATE TABLE clean.reviews (
    review_id NVARCHAR(50),
    order_id NVARCHAR(50),
    review_score INT,
    review_title NVARCHAR(MAX),
    review_message NVARCHAR(MAX),
    review_date DATETIME,
    answer_date DATETIME
);

-- Table 4: Orders
IF OBJECT_ID('clean.orders', 'U') IS NOT NULL DROP TABLE clean.orders;
CREATE TABLE clean.orders (
    order_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    order_status NVARCHAR(50),
    purchase_timestamp DATETIME,
    approved_at DATETIME,
    delivered_carrier_date DATETIME,
    delivered_customer_date DATETIME,
    estimated_delivery_date DATETIME,
    is_valid_order_timeline INT
);

-- Table 5: Order Items
IF OBJECT_ID('clean.order_items', 'U') IS NOT NULL DROP TABLE clean.order_items;
CREATE TABLE clean.order_items (
    order_id NVARCHAR(50),
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    order_item_id INT,
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- Table 6: Payments
IF OBJECT_ID('clean.payments', 'U') IS NOT NULL DROP TABLE clean.payments;
CREATE TABLE clean.payments (
    order_id NVARCHAR(50),
    payment_sequential INT,
    payment_type NVARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

-- Table 7: Product Category Name Translation
IF OBJECT_ID('clean.product_category_name', 'U') IS NOT NULL DROP TABLE clean.product_category_name;
CREATE TABLE clean.product_category_name (
    product_category_name NVARCHAR(100),
    product_category_name_english NVARCHAR(100)
);

-- Table 8: Products
IF OBJECT_ID('clean.products', 'U') IS NOT NULL DROP TABLE clean.products;
CREATE TABLE clean.products (
    product_id NVARCHAR(50),
    category_name NVARCHAR(100),
    name_length INT,
    description_length INT,
    photos_qty INT,
    weight_g DECIMAL(10,2),
    length_cm DECIMAL(10,2),
    height_cm DECIMAL(10,2),
    width_cm DECIMAL(10,2)
);

-- Table 9: Sellers
IF OBJECT_ID('clean.sellers', 'U') IS NOT NULL DROP TABLE clean.sellers;
CREATE TABLE clean.sellers (
    seller_id NVARCHAR(50),
    seller_zip_code INT,
    seller_city NVARCHAR(100),
    seller_state CHAR(2)
);
