-- QUALITY CHECKS FOR store.olist_customer_data

-- checking if there are any state name with length less than or more than 2.
-- result: length of states in the data is equal to 2.
SELECT DISTINCT customer_state 
FROM store.olist_customers_data
WHERE LEN(customer_state) <>2;

-- validating whether the zip code mentioned are of length 5 or not.
-- result: zip_code length in the data is valid and equal to 5.
SELECT customer_zip_code_prefix
FROM store.olist_customers_data
WHERE LEN(customer_zip_code_prefix) <> 5;

-- seeing if there are any duplicate entry in the data or not.
-- result: no duplicates are available.
SELECT customer_id , COUNT(*)
FROM store.olist_customers_data
GROUP BY customer_id
HAVING COUNT(*)>1;

-- checking for unwanted space
-- result: no unwanted space.
SELECT * FROM store.olist_customers_data
WHERE customer_city != TRIM(customer_city)

-- QUALITY CHECKS FOR store.olist_geolocation

-- checking how many times one zip code is repeating and what the lattitudes and longitudes are respect to that.
-- result: for one zip code different lat and lng are available. Fixing with taking the avg of all lat and lng for particular zip code.
SELECT TOP 10 
    geolocation_zip_code_prefix,
    COUNT(*) as duplicate_count
FROM store.olist_geolocation
GROUP BY geolocation_zip_code_prefix
ORDER BY duplicate_count DESC;

-- verifying with one example
SELECT * FROM store.olist_geolocation
WHERE geolocation_zip_code_prefix='24220'

-- checking for any unwanted space
-- result: no unwanted space.
SELECT * FROM store.olist_geolocation
WHERE geolocation_city != TRIM(geolocation_city)

-- QUALITY CHECKS FOR store.olist_order_reviews

-- check whether the review_score column has integer values or some text is present.
-- result: there are no text only integer values.
SELECT review_score 
FROM store.olist_orders_reviews
WHERE ISNUMERIC(review_score) = 0;

-- Scores outside 1-5 Range 
-- result: all review_score are valid
SELECT review_score, count(*)
FROM store.olist_orders_reviews
WHERE TRY_CAST(review_score AS INT) NOT BETWEEN 1 AND 5
GROUP BY review_score;

-- checking if there are any invalid values are present in month or day.
-- result: Valid values are in both column.
SELECT DISTINCT MONTH(review_answer_timestamp)
FROM store.olist_orders_reviews

SELECT DAY(review_answer_timestamp)
FROM store.olist_orders_reviews
WHERE DAY(review_answer_timestamp) > 31

-- QUALITY CHECKS FOR store.olist_order

-- checking if there are date where nulls are present.
-- result: nulls are present but that is ok to have. It is not representing any missing values.
SELECT * FROM store.olist_orders
WHERE order_delivered_carrier_date IS NULL OR order_delivered_customer_date IS NULL


-- QUALITY CHECKS FOR store.olist_orders_items

-- checking if there is any order item with no matching order.
-- result: such case does not exist. with every order item there is an order.
SELECT count(*) 
FROM store.olist_orders_items i
LEFT JOIN store.olist_orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL


-- QUALITY CHECKS FOR store.olist_orders_payments

-- checking if there are any type of payment which should not be present.
-- result: there is a payment type stating 'not_defined' which should not be there as it is not possible to not know the payment type.
SELECT DISTINCT(payment_type) 
FROM store.olist_orders_payments

-- checking if there are any payments for which there is no order listed.
-- result: such case is not present.
SELECT count(*) as ghost_payments
FROM store.olist_orders_payments p
LEFT JOIN store.olist_orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- checking if any payment has value zero.
-- result: we do have some values = 0.
SELECT * FROM store.olist_orders_payments 
WHERE CAST(payment_value AS DECIMAL(10,2)) <= 0;


-- QUALITY CHECKS FOR store.olist_product_category_name_translation

-- check for the un wanted space.
-- result: no unwanted space
SELECT * FROM store.olist_product_category_name_translation
WHERE product_category_name_english != TRIM(product_category_name_english)


-- QUALITY CHECKS FOR store.olist_products

-- checking for any duplicates.
-- result: no duplicates available.
SELECT product_id , COUNT(*)
FROM store.olist_products
GROUP BY product_id
HAVING COUNT(*)>1

-- checking if there exist values of these columns equal to zero.
-- result: product_weight_g has zero values which is not possible for a product having some height,length and width.
SELECT product_weight_g,product_length_cm,product_height_cm,product_width_cm,product_name_length,product_photos_qty
FROM store.olist_products
WHERE product_weight_g <= 0 
OR product_length_cm <= 0
OR product_height_cm <= 0
OR product_width_cm <= 0

-- checking if there are any nulls.
-- result: no nulls available.
SELECT COUNT(*) FROM store.olist_products
WHERE product_id IS NULL OR product_id = ''


-- QUALITY CHECKS FOR store.olist_sellers

-- checking for duplicates.
-- result: no duplicates.
SELECT seller_id , COUNT(*) 
FROM store.olist_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1

-- checking the length of the state if it is in valid range or not.
-- result: state name length is valid and equal to 2.
SELECT * FROM store.olist_sellers
WHERE LEN(seller_state) <>2

-- checking if any nulls are present.
-- result: no nulls.
SELECT * FROM store.olist_sellers
WHERE seller_city IS NULL OR seller_city = '' OR seller_zip_code_prefix IS NULL

-- QUALITY CHECKS FOR CROSS-TABLE INTEGRATION (Orders + Reviews)
-- checking for logical anomalies: reviews existing for orders with missing critical timestamps.
-- result: isolates rows where we have a review score but the order was apparently never purchased or delivered.

SELECT 
    r.order_id,
    r.review_id,
    r.review_score,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
FROM store.olist_orders_reviews r
LEFT JOIN store.olist_orders o 
    ON r.order_id = o.order_id
WHERE r.review_score IS NOT NULL 
  AND (o.order_purchase_timestamp IS NULL 
       OR o.order_delivered_customer_date IS NULL);

