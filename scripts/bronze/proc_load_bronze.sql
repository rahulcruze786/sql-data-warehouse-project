/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

Note:
    The BULK INSERT paths point to 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\'.
    Change them to the folder where you saved the datasets.
===============================================================================
*/



USE DataWareHouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS --Use it when you're deploying scripts repeatedly and you don't know whether the procedure already exists.
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '========================================================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '========================================================================';


		PRINT '-----------------------------------------------------------------------';
		PRINT 'LOADING CRM TABLES';

		
		PRINT '>> Truncating Table : bronze.crm_cust_info'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting data into : bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


		
		PRINT '>> Truncating Table : bronze.crm_prd_info'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting data into : bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


		
		PRINT '>> Truncating Table : bronze.crm_sales_details'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting data into : bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


		PRINT '-----------------------------------------------------------------------';
		PRINT 'LOADING ERP TABLES';

		PRINT '>> Truncating Table : bronze.erp_loc_a101'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting data into : bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';



		PRINT '>> Truncating Table : bronze.erp_cust_az12'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting data into : bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';


		PRINT '>> Truncating Table : bronze.erp_px_cat_g1v2'
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting data into : bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\STUDY\Big Data Engineer\SQL\Udemy-Baraa Khatib Salkini\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2, --Since first is the header row
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'second';
		PRINT '>>-----------------';

		SET @batch_end_time = GETDATE();
		PRINT '============================================='
		PRINT 'LANDING BRONZE LAYER IS COMPLETED'
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
