-- =================================================================
-- 1. Database Creation (Optional - Execute in 'master' if needed)
-- =================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MoneyMattersDb')
BEGIN
    CREATE DATABASE MoneyMattersDb;
END
GO

USE MoneyMattersDb;
GO

-- Assuming the script is executed in the target database.

-- Set a default schema if not using 'dbo' (best practice is to explicitly use 'dbo')
-- CREATE SCHEMA Core;
-- GO

-- =================================================================
-- 2. Currencies Table
-- =================================================================
-- Small reference table - Clustered index on PK is fine.
IF OBJECT_ID('dbo.Currencies', 'U') IS NOT NULL DROP TABLE dbo.Currencies;
CREATE TABLE dbo.Currencies (
    CurrencyID INT IDENTITY(1,1) NOT NULL,
    Symbol NVARCHAR(5) NOT NULL, -- e.g., '$', '€', '₹'
    Name NVARCHAR(50) NOT NULL,   -- e.g., 'US Dollar', 'Euro'
    CurrencyCode CHAR(3) NOT NULL, -- ISO 4217 standard, e.g., 'USD', 'EUR'

    CONSTRAINT PK_Currencies PRIMARY KEY CLUSTERED (CurrencyID ASC),
    CONSTRAINT UQ_Currencies_CurrencyCode UNIQUE (CurrencyCode),
    CONSTRAINT UQ_Currencies_Symbol UNIQUE (Symbol)
);
GO

-- =================================================================
-- 3. Users Table
-- =================================================================
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Username NVARCHAR(50) NOT NULL,
    PasswordHash CHAR(60) NOT NULL, -- Using CHAR for a fixed-length hash like bcrypt
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Users_CreatedTimestamp DEFAULT (SYSDATETIME()),
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (1), -- Default to active
    UpdatedTimestamp DATETIME2(7) NULL, -- Nullable, updated on modification

    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserID ASC),
    -- Unique constraints as specified
    CONSTRAINT UQ_Users_Email UNIQUE NONCLUSTERED (Email),
    CONSTRAINT UQ_Users_Username UNIQUE NONCLUSTERED (Username)
);
GO

-- Index on IsActive for filtering
-- CREATE NONCLUSTERED INDEX IX_Users_IsActive ON dbo.Users (IsActive);
-- GO

-- =================================================================
-- 4. Accounts Table
-- =================================================================
-- Stores the user's financial accounts (e.g., Personal Savings, Joint Checking)
IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL DROP TABLE dbo.Accounts;
CREATE TABLE dbo.Accounts (
    AccountID INT IDENTITY(1,1) NOT NULL,
    AccountHolder INT NOT NULL, -- FK to Users.UserID
    AccountName NVARCHAR(100) NOT NULL,
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Accounts_CreatedTimestamp DEFAULT (SYSDATETIME()),
    UpdatedTimestamp DATETIME2(7) NULL,

    CONSTRAINT PK_Accounts PRIMARY KEY CLUSTERED (AccountID ASC),
    CONSTRAINT FK_Accounts_AccountHolder FOREIGN KEY (AccountHolder)
        REFERENCES dbo.Users (UserID)
);
GO

-- Index on the FK for faster joins and lookups
-- CREATE NONCLUSTERED INDEX IX_Accounts_AccountHolder ON dbo.Accounts (AccountHolder);
-- GO

-- =================================================================
-- 5. Banks Table
-- =================================================================
-- Stores bank/financial institution details associated with an Account
IF OBJECT_ID('dbo.Banks', 'U') IS NOT NULL DROP TABLE dbo.Banks;
CREATE TABLE dbo.Banks (
    BankID INT IDENTITY(1,1) NOT NULL,
    AccountID INT NOT NULL, -- FK to Accounts.AccountID (linking bank details to an account)
    BankName NVARCHAR(100) NOT NULL,
    BankDescription NVARCHAR(255) NULL,
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Banks_CreatedTimestamp DEFAULT (SYSDATETIME()),
    UpdatedTimestamp DATETIME2(7) NULL,

    CONSTRAINT PK_Banks PRIMARY KEY CLUSTERED (BankID ASC),
    CONSTRAINT FK_Banks_AccountID FOREIGN KEY (AccountID)
        REFERENCES dbo.Accounts (AccountID)
);
GO

-- CREATE NONCLUSTERED INDEX IX_Banks_AccountID ON dbo.Banks (AccountID);
-- GO

-- =================================================================
-- 6. TransactionTypes Table
-- =================================================================
-- Stores major categories (e.g., Food, Shopping, Investment)
IF OBJECT_ID('dbo.TransactionTypes', 'U') IS NOT NULL DROP TABLE dbo.TransactionTypes;
CREATE TABLE dbo.TransactionTypes (
    TransactionTypeID INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(50) NOT NULL, -- e.g., 'Food', 'Entertainment'

    CONSTRAINT PK_TransactionTypes PRIMARY KEY CLUSTERED (TransactionTypeID ASC),
    CONSTRAINT UQ_TransactionTypes_Name UNIQUE (Name)
);
GO

-- =================================================================
-- 7. TransactionSubtypes Table
-- =================================================================
-- Stores sub-categories for finer granularity (e.g., Food -> Groceries, Food -> Restaurant)
IF OBJECT_ID('dbo.TransactionSubtypes', 'U') IS NOT NULL DROP TABLE dbo.TransactionSubtypes;
CREATE TABLE dbo.TransactionSubtypes (
    TransactionSubtypeID INT IDENTITY(1,1) NOT NULL,
    TransactionTypeID INT NOT NULL, -- FK to TransactionTypes.TransactionTypeID
    Name NVARCHAR(50) NOT NULL,     -- e.g., 'Groceries', 'Bar', 'IRA Contribution'

    CONSTRAINT PK_TransactionSubtypes PRIMARY KEY CLUSTERED (TransactionSubtypeID ASC),
    CONSTRAINT FK_TransactionSubtypes_TransactionTypeID FOREIGN KEY (TransactionTypeID)
        REFERENCES dbo.TransactionTypes (TransactionTypeID),
    -- Constraint to ensure the subtype name is unique within a type
    CONSTRAINT UQ_TransactionSubtypes_TypeID_Name UNIQUE (TransactionTypeID, Name)
);
GO

-- CREATE NONCLUSTERED INDEX IX_TransactionSubtypes_TransactionTypeID ON dbo.TransactionSubtypes (TransactionTypeID);
-- GO

-- =================================================================
-- 8. Transactions Table
-- =================================================================
-- The main fact table, potentially the largest
IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;
CREATE TABLE dbo.Transactions (
    TransactionID BIGINT IDENTITY(1,1) NOT NULL, -- Using BIGINT for a potentially massive transaction count
    TransactionSubtypeID INT NOT NULL, -- FK to TransactionSubtypes.TransactionSubtypeID
    BankID INT NOT NULL,               -- FK to Banks.BankID (The account/bank that conducted the transaction)
    CurrencyID INT NOT NULL,           -- FK to Currencies.CurrencyID
    TransactionAmount DECIMAL(18, 4) NOT NULL, -- Using DECIMAL for financial precision
    IsCredited BIT NOT NULL,           -- TRUE for income/credit, FALSE for expense/debit
    Description NVARCHAR(500) NULL,
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Transactions_CreatedTimestamp DEFAULT (SYSDATETIME()),
    UpdatedTimestamp DATETIME2(7) NULL,

    CONSTRAINT PK_Transactions PRIMARY KEY CLUSTERED (TransactionID ASC),
    CONSTRAINT FK_Transactions_TransactionSubtypeID FOREIGN KEY (TransactionSubtypeID)
        REFERENCES dbo.TransactionSubtypes (TransactionSubtypeID),
    CONSTRAINT FK_Transactions_BankID FOREIGN KEY (BankID)
        REFERENCES dbo.Banks (BankID),
    CONSTRAINT FK_Transactions_CurrencyID FOREIGN KEY (CurrencyID)
        REFERENCES dbo.Currencies (CurrencyID),
    -- Ensure transaction amount is non-negative
    CONSTRAINT CHK_Transactions_AmountPositive CHECK (TransactionAmount >= 0)
);
GO

-- Composite index for the most common queries (e.g., "show me all transactions for this bank in date range")
-- CREATE NONCLUSTERED INDEX IX_Transactions_BankID_CreatedTimestamp
--    ON dbo.Transactions (BankID, CreatedTimestamp DESC)
--    INCLUDE (TransactionAmount, IsCredited);
-- GO

---- Index for categorization lookups
-- CREATE NONCLUSTERED INDEX IX_Transactions_TransactionSubtypeID ON dbo.Transactions (TransactionSubtypeID);
-- GO

---- Index for currency lookups (if needed for conversions)
-- CREATE NONCLUSTERED INDEX IX_Transactions_CurrencyID ON dbo.Transactions (CurrencyID);
-- GO

-- =================================================================
-- 9. Stored Procedure for Updating Timestamp (Best Practice)
-- =================================================================
-- Best practice: Use a stored procedure or trigger to manage UpdatedTimestamp
/*
-- Example Trigger (for Azure SQL or SQL Server)
CREATE TRIGGER TR_Users_UpdateTimestamp
ON dbo.Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE U
    SET UpdatedTimestamp = SYSDATETIME()
    FROM dbo.Users AS U
    INNER JOIN inserted AS I ON U.UserID = I.UserID;
END
GO
*/