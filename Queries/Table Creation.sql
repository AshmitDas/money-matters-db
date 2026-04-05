-- =================================================================
-- 1. Currencies Table
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
-- 2. Users Table
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


-- =================================================================
-- 3. Banks Table
-- =================================================================
-- Stores bank/financial institution details associated with an Account
IF OBJECT_ID('dbo.Banks', 'U') IS NOT NULL DROP TABLE dbo.Banks;
CREATE TABLE dbo.Banks (
    BankID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL, -- FK to Users.UserID (linking bank details to an User)
    BankName NVARCHAR(100) NOT NULL,
    BankDescription NVARCHAR(255) NULL,
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Banks_CreatedTimestamp DEFAULT (SYSDATETIME()),
    UpdatedTimestamp DATETIME2(7) NULL,

    CONSTRAINT PK_Banks PRIMARY KEY CLUSTERED (BankID ASC),
    CONSTRAINT FK_Banks_UserID FOREIGN KEY (UserID)
        REFERENCES dbo.Users (UserID)
);
GO

-- =================================================================
-- 4. TransactionTypes Table
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
-- 5. TransactionSubtypes Table
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

-- =================================================================
-- 6. Transactions Table
-- =================================================================
-- The main fact table, potentially the largest
IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;
CREATE TABLE dbo.Transactions (
    TransactionID BIGINT IDENTITY(1,1) NOT NULL, -- Using BIGINT for a potentially massive transaction count
    TransactionSubtypeID INT NOT NULL, -- FK to TransactionSubtypes.TransactionSubtypeID
    BankID INT NOT NULL,               -- FK to Banks.BankID (The account/bank that conducted the transaction)
    CurrencyID INT NOT NULL,           -- FK to Currencies.CurrencyID
    TransactionAmount DECIMAL(18, 4) NOT NULL, -- Using DECIMAL for financial precision
    ForeignCurrencyID INT NOT NULL,    -- FK to Currencies.CurrencyID
    ForeignTransactionAmount DECIMAL(18, 4) NOT NULL, -- Using DECIMAL for financial precision
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
    CONSTRAINT FK_Transactions_ForeignCurrencyID FOREIGN KEY (ForeignCurrencyID)
        REFERENCES dbo.Currencies (CurrencyID),
    -- Ensure transaction amount is non-negative
    CONSTRAINT CHK_Transactions_AmountPositive CHECK (TransactionAmount >= 0 and ForeignTransactionAmount >= 0)
);
GO