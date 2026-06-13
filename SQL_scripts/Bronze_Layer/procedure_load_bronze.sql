/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> store)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'store' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC store.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE store.load_bronze AS
BEGIN 
    DECLARE @start_time DATETIME,@end_time DATETIME;
    BEGIN TRY
        print('=================================================');
        print('Loading bronze layer');
        print('=================================================');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_customers_data');
        TRUNCATE TABLE store.olist_customers_data;
        

        print('>>> Inserting data into: store.olist_customers_data');
        BULK INSERT store.olist_customers_data
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_customers_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'seconds');
        print('--------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_geolocation')
        TRUNCATE TABLE store.olist_geolocation;

        print('>>> Inserting data into: store.olist_geolocation');
        BULK INSERT store.olist_geolocation
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_geolocation_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_order_reviews')
        TRUNCATE TABLE store.olist_orders_reviews;

        print('>>> Inserting data into: store.olist_order_reviews');
        BULK INSERT store.olist_orders_reviews
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',
            FIELDQUOTE = '"',      
            ROWTERMINATOR = '\n',     
            CODEPAGE = '65001',        
            TABLOCK
            --MAXERRORS = 50, 
            --ERRORFILE = 'C:\Users\laksh kumar\Documents\Olist_datasets\reviews_error_log.csv'
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_orders')
        TRUNCATE TABLE store.olist_orders;

        print('>>> Inserting data into: store.olist_orders');
        BULK INSERT store.olist_orders
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_orders_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_orders_items')
        TRUNCATE TABLE store.olist_orders_items;

        print('>>> Inserting data into: store.olist_orders_items');
        BULK INSERT store.olist_orders_items
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_order_items_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_orders_payments')
        TRUNCATE TABLE store.olist_orders_payments;

        print('>>> Inserting data into: store.olist_orders_payments');
        BULK INSERT store.olist_orders_payments
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_order_payments_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_product_category_name_translation')
        TRUNCATE TABLE store.olist_product_category_name_translation;

        print('>>> Inserting data into: store.olist_product_category_name_translation');
        BULK INSERT store.olist_product_category_name_translation
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\product_category_name_translation.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_products')
        TRUNCATE TABLE store.olist_products;

        print('>>> Inserting data into: store.olist_products');
        BULK INSERT store.olist_products
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_products_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

        SET @start_time = GETDATE();
        print('>>>Truncating The Table: store.olist_sellers')
        TRUNCATE TABLE store.olist_sellers;

        print('>>> Inserting data into: store.olist_sellers');
        BULK INSERT store.olist_sellers
        FROM 'C:\Users\laksh kumar\Documents\Olist_datasets\olist_sellers_dataset.csv'
        WITH (
            FORMAT = 'CSV',             
            FIRSTROW = 2,               
            FIELDTERMINATOR = ',',      
            ROWTERMINATOR = '0x0a',     
            CODEPAGE = '65001',        
            TABLOCK                     
        );
        SET @end_time = GETDATE();
        print('>>> Load Duration: '+ CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR) + 'seconds');
        print('----------------------------------------------------');

    END TRY
    BEGIN CATCH
        print('Error occured during loading bronze layer');
        print('Error message' + ERROR_MESSAGE());
    END CATCH;
END
