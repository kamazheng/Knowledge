# Mssql
## Drop tables

``` sql

-- Get a list of tables and views in the current database
SELECT table_catalog [database], table_schema [schema], table_name name, table_type type
FROM INFORMATION_SCHEMA.TABLES
GO

```

``` sql

-- delete all the tables and views in the current database
-- Step 1: Disable all foreign key constraints to avoid dependency issues
DECLARE @DropFKs NVARCHAR(MAX) = '';
SELECT @DropFKs += 'ALTER TABLE [' + SCHEMA_NAME(schema_id) + '].[' + OBJECT_NAME(parent_object_id) + '] DROP CONSTRAINT [' + name + '];' 
FROM sys.foreign_keys;

EXEC sp_executesql @DropFKs;

-- Step 2: Drop all tables
DECLARE @DropTables NVARCHAR(MAX) = '';
SELECT @DropTables += 'DROP TABLE [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' 
FROM sys.tables;

EXEC sp_executesql @DropTables;

```

