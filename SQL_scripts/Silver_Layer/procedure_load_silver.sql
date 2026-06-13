/*
===============================================================================
Stored Procedure: Load Silver Layer (store -> clean)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'clean' schema tables from the 'store' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC clean.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE clean.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME;
    BEGIN TRY
        print('=================================================');
        print('Loading Silver layer');
        print('=================================================');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.customers');
        TRUNCATE TABLE clean.customers;

        print('>>>Inserting Data Into: clean.customers')
        INSERT INTO clean.customers
        SELECT 
            CAST(customer_id AS NVARCHAR(50)) AS customer_id,
            CAST(customer_unique_id AS NVARCHAR(50)) AS customer_unique_id,
            CAST(customer_zip_code_prefix AS INT) AS customer_zip_code,
            UPPER(TRIM(CAST(customer_city AS NVARCHAR(100)))) AS customer_city,
            UPPER(TRIM(CAST(customer_state AS CHAR(2)))) AS customer_state
        FROM store.olist_customers_data;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.geolocation');
        TRUNCATE TABLE clean.geolocation;

        print('>>>Inserting Data Into: clean.geolocation')
        INSERT INTO clean.geolocation
        SELECT 
            CAST(geolocation_zip_code_prefix AS INT) AS zip_code,
            CAST(AVG(CAST(geolocation_lat AS FLOAT)) AS DECIMAL(18,15)) AS lat,
            CAST(AVG(CAST(geolocation_lng AS FLOAT)) AS DECIMAL(18,15)) AS lng,
            UPPER(TRIM(CAST(MAX(geolocation_city) AS NVARCHAR(100)))) AS city,
            UPPER(TRIM(CAST(MAX(geolocation_state) AS CHAR(2)))) AS state
        FROM store.olist_geolocation
        GROUP BY geolocation_zip_code_prefix;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.reviews');
        TRUNCATE TABLE clean.reviews;

        print('>>>Inserting Data Into: clean.reviews')
        INSERT INTO clean.reviews
        SELECT 
            review_id,
            order_id,
            TRY_CAST(review_score AS INT) AS review_score,
            COALESCE(NULLIF(TRIM(CAST(review_comment_title AS NVARCHAR(MAX))), ''), 'No Title') AS review_title,
            COALESCE(NULLIF(TRIM(CAST(review_comment_message AS NVARCHAR(MAX))), ''), 'No Message') AS review_message,
            TRY_CAST(review_creation_date AS DATETIME) AS review_date,
            TRY_CAST(review_answer_timestamp AS DATETIME) AS answer_date
        FROM store.olist_orders_reviews 
        WHERE review_id IS NOT NULL;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.orders');
        TRUNCATE TABLE clean.orders;

        print('>>>Inserting Data Into: clean.orders')
        INSERT INTO clean.orders
        SELECT 
            o.order_id, 
            o.customer_id, 
            o.order_status, 
            TRY_CAST(o.order_purchase_timestamp AS DATETIME) AS purchase_timestamp, 
            TRY_CAST(o.order_approved_at AS DATETIME) AS approved_at, 
            TRY_CAST(o.order_delivered_carrier_date AS DATETIME) AS delivered_carrier_date, 
            TRY_CAST(o.order_delivered_customer_date AS DATETIME) AS delivered_customer_date, 
            TRY_CAST(o.order_estimated_delivery_date AS DATETIME) AS estimated_delivery_date,
    
            CASE 
                WHEN TRY_CAST(o.order_purchase_timestamp AS DATETIME) IS NULL THEN 0
                WHEN o.order_status = 'delivered' AND TRY_CAST(o.order_delivered_customer_date AS DATETIME) IS NULL THEN 0
                WHEN EXISTS (
                    SELECT 1 FROM store.olist_orders_reviews r 
                    WHERE r.order_id = o.order_id AND r.review_score IS NOT NULL
                ) AND (TRY_CAST(o.order_purchase_timestamp AS DATETIME) IS NULL OR TRY_CAST(o.order_delivered_customer_date AS DATETIME) IS NULL)
                THEN 0 
                ELSE 1 
            END AS is_valid_order_timeline
        FROM store.olist_orders o;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.order_items');
        TRUNCATE TABLE clean.order_items;

        print('>>>Inserting Data Into: clean.order_items')
        INSERT INTO clean.order_items
        SELECT
            TRIM(CAST(order_id AS NVARCHAR(50))) AS order_id,
            TRIM(CAST(product_id AS NVARCHAR(50))) AS product_id,
            TRIM(CAST(seller_id AS NVARCHAR(50))) AS seller_id,
            TRY_CAST(order_item_id AS INT) AS order_item_id,
            TRY_CAST(shipping_limit_date AS DATETIME) AS shipping_limit_date,
            TRY_CAST(price AS DECIMAL(10,2)) AS price,
            TRY_CAST(freight_value AS DECIMAL(10,2)) AS freight_value
        FROM store.olist_orders_items;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.payments');
        TRUNCATE TABLE clean.payments;

        print('>>>Inserting Data Into: clean.payments')
        INSERT INTO clean.payments
        SELECT 
            order_id,
            TRY_CAST(payment_sequential AS INT) AS payment_sequential,
            REPLACE(payment_type, '_', ' ') AS payment_type,
            TRY_CAST(payment_installments AS INT) AS payment_installments,
            TRY_CAST(payment_value AS DECIMAL(10,2)) AS payment_value
        FROM store.olist_orders_payments
        WHERE 
            payment_type <> 'not_defined'
            AND TRY_CAST(payment_value AS DECIMAL(10,2)) > 0;
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');


        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.product_category_name');
        TRUNCATE TABLE clean.product_category_name;

        print('>>>Inserting Data Into: clean.product_category_name')
        INSERT INTO clean.product_category_name
        SELECT 
            REPLACE(product_category_name , '_',' ') AS product_category_name,
            REPLACE(product_category_name_english , '_',' ') AS product_category_name_english
        FROM store.olist_product_category_name_translation
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.products');
        TRUNCATE TABLE clean.products;

        print('>>>Inserting Data Into: clean.products')
        INSERT INTO clean.products
        SELECT 
            product_id ,
            ISNULL(NULLIF(TRIM(product_category_name), ''), 'Unknown') AS category_name,
            ISNULL(TRY_CAST(product_name_length AS INT), 0) AS name_length,
            ISNULL(TRY_CAST(product_description_length AS INT), 0) AS description_length,
            ISNULL(TRY_CAST(product_photos_qty AS INT), 0) AS photos_qty,
            CASE WHEN TRY_CAST(product_weight_g AS DECIMAL(10,2)) <= 0 OR product_weight_g IS NULL THEN 1.0 
                 ELSE TRY_CAST(product_weight_g AS DECIMAL(10,2)) 
            END AS weight_g,
            CASE WHEN TRY_CAST(product_length_cm AS DECIMAL(10,2)) <= 0 OR product_length_cm IS NULL THEN 1.0 
                 ELSE TRY_CAST(product_length_cm AS DECIMAL(10,2)) 
            END AS length_cm,
            CASE WHEN TRY_CAST(product_height_cm AS DECIMAL(10,2)) <= 0 OR product_height_cm IS NULL THEN 1.0 
                 ELSE TRY_CAST(product_height_cm AS DECIMAL(10,2)) 
            END AS height_cm,
            CASE WHEN TRY_CAST(product_width_cm AS DECIMAL(10,2)) <= 0 OR product_width_cm IS NULL THEN 1.0 
                 ELSE TRY_CAST(product_width_cm AS DECIMAL(10,2)) 
            END AS width_cm
        FROM store.olist_products
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: clean.sellers');
        TRUNCATE TABLE clean.sellers;

        print('>>>Inserting Data Into: clean.sellers')
        INSERT INTO clean.sellers
        SELECT 
            seller_id,
            CAST(seller_zip_code_prefix AS INT) seller_zip_code,
            TRIM(CAST(seller_city AS NVARCHAR(100))) AS seller_city,
            TRIM(CAST(seller_state AS CHAR(2))) AS seller_state
        FROM store.olist_sellers
        SET @end_time = GETDATE();
        print('Load Duration '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR)+ 'seconds');
        print('---------------------------------------------------');
    END TRY
    BEGIN CATCH
        print('Error occured during loading bronze layer');
        print('Error message' + ERROR_MESSAGE());
    END CATCH;
END
