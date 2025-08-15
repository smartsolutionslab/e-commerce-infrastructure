-- Create databases for all services
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ECommerce_CustomerManagement')
BEGIN
    CREATE DATABASE ECommerce_CustomerManagement;
    PRINT 'Database ECommerce_CustomerManagement created successfully';
END

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ECommerce_ProductCatalog')
BEGIN
    CREATE DATABASE ECommerce_ProductCatalog;
    PRINT 'Database ECommerce_ProductCatalog created successfully';
END

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ECommerce_OrderManagement')
BEGIN
    CREATE DATABASE ECommerce_OrderManagement;
    PRINT 'Database ECommerce_OrderManagement created successfully';
END

-- Create service user
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'ecommerce_service')
BEGIN
    CREATE LOGIN ecommerce_service WITH PASSWORD = 'ECommerce123!';
    PRINT 'Login ecommerce_service created successfully';
END

-- Grant permissions
USE ECommerce_CustomerManagement;
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ecommerce_service')
BEGIN
    CREATE USER ecommerce_service FOR LOGIN ecommerce_service;
    ALTER ROLE db_datareader ADD MEMBER ecommerce_service;
    ALTER ROLE db_datawriter ADD MEMBER ecommerce_service;
    ALTER ROLE db_ddladmin ADD MEMBER ecommerce_service;
END

USE ECommerce_ProductCatalog;
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ecommerce_service')
BEGIN
    CREATE USER ecommerce_service FOR LOGIN ecommerce_service;
    ALTER ROLE db_datareader ADD MEMBER ecommerce_service;
    ALTER ROLE db_datawriter ADD MEMBER ecommerce_service;
    ALTER ROLE db_ddladmin ADD MEMBER ecommerce_service;
END

USE ECommerce_OrderManagement;
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ecommerce_service')
BEGIN
    CREATE USER ecommerce_service FOR LOGIN ecommerce_service;
    ALTER ROLE db_datareader ADD MEMBER ecommerce_service;
    ALTER ROLE db_datawriter ADD MEMBER ecommerce_service;
    ALTER ROLE db_ddladmin ADD MEMBER ecommerce_service;
END

PRINT 'All databases and users configured successfully';
