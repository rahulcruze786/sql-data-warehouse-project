/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it not already exists.
    If the database exists, it will not recreated since already exists. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold' if these are not exists.

📌 Notes :
    CREATE DATABASE → allowed inside BEGIN…END.
    CREATE SCHEMA → not allowed inside BEGIN…END because it must be the first statement in a batch.
    Solution → wrap it in EXEC('...') or run it directly without conditional logic.

    👉 Think of it like this: Database creation is flexible, schema creation is strict.
*/

-- Switch to master to create the database
USE master;
GO

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name='DataWareHouse')
BEGIN
	CREATE DATABASE DataWareHouse;
END
GO

-- Switch to the new database
USE DataWareHouse;
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas where name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas where name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas where name = 'gold')
    EXEC('CREATE SCHEMA gold');
