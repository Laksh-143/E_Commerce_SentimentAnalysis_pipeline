IF OBJECT_ID('df.dim_customers','U') IS NOT NULL
    DROP TABLE df.dim_customers
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code,
    customer_city,
    customer_state
INTO df.dim_customers
FROM clean.customers
GO

IF OBJECT_ID('df.dim_sellers','U') IS NOT NULL
    DROP TABLE df.dim_sellers

SELECT 
    seller_id,
    seller_zip_code,
    seller_city,
    seller_state
INTO df.dim_sellers
FROM clean.sellers
GO

IF OBJECT_ID('df.dim_geolocation','U') IS NOT NULL
    DROP TABLE df.dim_geolocation

SELECT 
    zip_code,
    lat,
    lng,
    city,
    state
INTO df.dim_geolocation
FROM clean.geolocation
GO

IF OBJECT_ID('df.dim_products','U') IS NOT NULL
    DROP TABLE df.dim_products

SELECT 
    product_id,
    COALESCE(t.product_category_name_english, p.category_name, 'Unknown') AS category_name,
    p.name_length,
    p.description_length,
    p.photos_qty,
    p.weight_g,
    p.length_cm,
    p.height_cm,
    p.width_cm
INTO df.dim_products
FROM clean.products p
LEFT JOIN clean.product_category_name t 
ON p.category_name = t.product_category_name
GO

IF OBJECT_ID('df.dim_date','U') IS NOT NULL
    DROP TABLE df.dim_date

DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2019-12-31';

WITH DateCTE AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateCTE
    WHERE DateValue < @EndDate
)
SELECT 
    CAST(FORMAT(DateValue, 'yyyyMMdd') AS INT) AS date_key, 
    DateValue AS full_date,
    YEAR(DateValue) AS calendar_year,
    --MONTH(DateValue) AS calendar_month,
    DATENAME(MONTH, DateValue) AS month_name,
    DATEPART(QUARTER, DateValue) AS calendar_quarter,
    DAY(DateValue) AS day_of_month,
    DATENAME(WEEKDAY, DateValue) AS day_of_week,
    CASE WHEN DATENAME(WEEKDAY, DateValue) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS is_weekend
INTO df.dim_date
FROM DateCTE
OPTION (MAXRECURSION 0);
GO

IF OBJECT_ID('df.dim_reviews','U') IS NOT NULL
    DROP TABLE df.dim_reviews

SELECT
    review_id,
    review_title,
    review_message
INTO df.dim_reviews
FROM clean.reviews
where review_message != 'No Message' or review_title != 'No Title';
GO

IF OBJECT_ID('df.Fact_Orders','U') IS NOT NULL
    DROP TABLE df.Fact_Orders

SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    CAST(FORMAT(o.purchase_timestamp, 'yyyyMMdd') AS INT) AS purchase_date_key,
    oi.order_item_id,
    DATEDIFF(DAY, oi.shipping_limit_date, o.delivered_carrier_date) AS days_late_shipping,
    DATEDIFF(DAY, o.estimated_delivery_date, o.delivered_customer_date) AS days_late_delivery,
    
    CASE 
        WHEN o.estimated_delivery_date IS NULL THEN 'Estimate Unknown'
        WHEN o.delivered_customer_date > o.estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_performance_status,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_order_value

INTO df.Fact_Orders
FROM clean.order_items oi
JOIN clean.orders o ON oi.order_id = o.order_id
LEFT JOIN clean.reviews r ON oi.order_id = r.order_id

WHERE o.is_valid_order_timeline = 1 
  AND o.order_status = 'delivered';
GO

IF OBJECT_ID('df.Fact_Payments','U') IS NOT NULL
    DROP TABLE df.Fact_Payments

SELECT 
    p.order_id,
    o.customer_id,            
    p.payment_sequential,    
    p.payment_type,           
    p.payment_installments,   
    p.payment_value           

INTO df.Fact_Payments
FROM clean.payments p
JOIN clean.orders o 
    ON p.order_id = o.order_id
WHERE o.is_valid_order_timeline = 1;
GO

IF OBJECT_ID('df.Fact_Reviews','U') IS NOT NULL
    DROP TABLE df.Fact_Reviews

SELECT 
    review_id,
    order_id,
    CAST(FORMAT(review_date, 'yyyyMMdd')as INT)as review_creation_date_key,
    CAST(FORMAT(answer_date, 'yyyyMMdd')as INT)as review_answer_date_key,
    review_score
INTO df.Fact_Reviews
FROM clean.reviews
GO


