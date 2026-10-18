/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time =  GETDATE();
        PRINT '========================================================================';
	    PRINT 'LOADING SILVER LAYER';
	    PRINT '========================================================================';


	    PRINT '-----------------------------------------------------------------------';
	    PRINT 'LOADING CRM TABLES';

        PRINT '>> Truncate Table : silver.crm_cust_info';
        IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting data Into : silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
        SELECT cst_id,cst_key,
	        TRIM(cst_firstname) AS cst_firstname,
	        TRIM(cst_lastname) AS cst_lastname,
	        CASE
		        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		        ELSE 'n/a'
	        END AS cst_marital_status,
	        CASE 
		        WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'Male'
		        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		        ELSE 'n/a'
	        END AS cst_gndr,
	        cst_create_date
        FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_latest FROM bronze.crm_cust_info) AS t WHERE flag_latest=1 and cst_id IS NOT NULL;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


        PRINT '============================================';
        PRINT '>> Truncate Table : silver.crm_prd_info';
        IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting data Into : silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
                prd_id,
                cat_id,
                prd_key,
                prd_nm,
                prd_cost,
                prd_line,
                prd_start_dt,
                prd_end_dt
        
                )
              SELECT prd_id, 
               REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- Since we have a erp_px_cat_g1v2 table in which we have category id to join eg. AC_BR
               SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, -- Since we have a crm_sales_details table in which we have product key to join eg.HL-U509-R
               prd_nm, --No extra spaces detected
               ISNULL(prd_cost,0) AS prd_cost, -- NULL values detected so
               CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
               END AS prd_line,
               CAST(prd_start_dt AS DATE) AS prd_start_dt,
               CAST(LEAD(prd_start_dt,1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
          FROM bronze.crm_prd_info;
          SET @end_time = GETDATE();
          PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		  PRINT '>>-----------------';

        PRINT '============================================';
        PRINT '>> Truncate Table : silver.crm_sales_details';
        IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting data Into : silver.crm_sales_details';
          INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT sls_ord_num,
		        sls_prd_key,
		        sls_cust_id,
		        CASE
			        WHEN LEN(sls_order_dt)!=8 or sls_order_dt <= 0 THEN NULL
			        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) -- First, convert the integer value to a VARCHAR, then convert the VARCHAR to a DATE, because SQL Server does not allow direct conversion from INTEGER to DATE
		        END AS sls_order_dt,
		        CASE
			        WHEN LEN(sls_ship_dt)!=8 or sls_ship_dt <= 0 THEN NULL
			        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) -- First, convert the integer value to a VARCHAR, then convert the VARCHAR to a DATE, because SQL Server does not allow direct conversion from INTEGER to DATE
		        END AS sls_ship_dt,
		        CASE
			        WHEN LEN(sls_due_dt)!=8 or sls_due_dt <= 0 THEN NULL
			        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) -- First, convert the integer value to a VARCHAR, then convert the VARCHAR to a DATE, because SQL Server does not allow direct conversion from INTEGER to DATE
		        END AS sls_due_dt,
		        --sls_sales As old_sls_sales,
		        CASE
			        WHEN sls_sales IS NULL or sls_sales<=0 or sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
			        ELSE sls_sales
		        END AS sls_sales,
		        sls_quantity,
		        --sls_price AS old_sls_price,
		        CASE
			        WHEN sls_price IS NULL OR sls_price<=0 THEN sls_sales/NULLIF(sls_quantity,0)
			        ELSE sls_price
		        END AS sls_price
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';

        PRINT '-----------------------------------------------------------------------';
		    PRINT 'LOADING ERP TABLES';


        PRINT '============================================';
        PRINT '>> Truncate Table : silver.erp_cust_az12';
        IF OBJECT_ID('silver.erp_cust_az12','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting data Into : silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
          cid,
          bdate,
          gen
          )

        SELECT CASE
            WHEN cid LIKE 'NAS%' THEN  SUBSTRING(cid,4,LEN(cid))
            ELSE cid
        END AS cid,
        CASE
            WHEN bdate> GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) = 'F' OR UPPER(TRIM(gen)) = 'FEMALE' THEN 'Female'
            WHEN UPPER(TRIM(gen)) = 'M' OR UPPER(TRIM(gen)) = 'MALE' THEN 'Male'
            ELSE 'n/a'
        END AS gen
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


        PRINT '============================================';
        PRINT '>> Truncate Table : silver.erp_loc_a101';
        IF OBJECT_ID('silver.erp_loc_a101','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting data Into : silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101(
        cid, cntry
        )
        SELECT REPLACE(cid,'-','') AS cid,
               CASE
                   WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                   WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
                   WHEN UPPER(TRIM(cntry)) IS NULL OR UPPER(TRIM(cntry))=''  THEN 'n/a'
                   ELSE TRIM(cntry)
                END AS cntry
          FROM .bronze.erp_loc_a101;
          SET @end_time = GETDATE();
          PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		  PRINT '>>-----------------';


          PRINT '============================================';
        PRINT '>> Truncate Table : silver.erp_px_cat_g1v2';
        IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
        SET @start_time = GETDATE();
	        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting data Into : silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
        )
        SELECT * FROM bronze.erp_px_cat_g1v2

        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';

        SET @batch_end_time = GETDATE();
        PRINT '============================================='
		PRINT 'LANDING SILVER LAYER IS COMPLETED'
		PRINT '  - Total Load Duration :' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'second';
		PRINT '============================================='

    END TRY
    BEGIN CATCH
        PRINT '========================================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================================='
    END CATCH
END
