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
-- 2. BankAccounts Table
-- =================================================================
-- Stores bank/financial details associated with an Account
IF OBJECT_ID('dbo.BankAccounts', 'U') IS NOT NULL DROP TABLE dbo.Banks;
CREATE TABLE dbo.BankAccounts (
    BankAccountID INT IDENTITY(1,1) NOT NULL,
    UserOid UNIQUEIDENTIFIER NOT NULL, -- Azure AD Object ID
    BankAccountName NVARCHAR(100) NOT NULL,
    BankAccountDescription NVARCHAR(255) NULL,
    CreatedTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_Banks_CreatedTimestamp DEFAULT (SYSDATETIME()),
    UpdatedTimestamp DATETIME2(7) NULL,

    CONSTRAINT PK_BankAccounts PRIMARY KEY CLUSTERED (BankAccountID ASC)
);
GO

-- =================================================================
-- 3. TransactionTypes Table
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
-- 4. TransactionSubtypes Table
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
-- 5. Transactions Table
-- =================================================================
-- The main fact table, potentially the largest
IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;
CREATE TABLE dbo.Transactions (
    TransactionID BIGINT IDENTITY(1,1) NOT NULL, -- Using BIGINT for a potentially massive transaction count
    TransactionSubtypeID INT NOT NULL, -- FK to TransactionSubtypes.TransactionSubtypeID
    BankAccountID INT NOT NULL,               -- FK to Banks.BankAccountID (The bank account that conducted the transaction)
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
    CONSTRAINT FK_Transactions_BankAccountID FOREIGN KEY (BankAccountID)
        REFERENCES dbo.BankAccounts (BankAccountID),
    CONSTRAINT FK_Transactions_CurrencyID FOREIGN KEY (CurrencyID)
        REFERENCES dbo.Currencies (CurrencyID),
    CONSTRAINT FK_Transactions_ForeignCurrencyID FOREIGN KEY (ForeignCurrencyID)
        REFERENCES dbo.Currencies (CurrencyID),
    -- Ensure transaction amount is non-negative
    CONSTRAINT CHK_Transactions_AmountPositive CHECK (TransactionAmount >= 0 and ForeignTransactionAmount >= 0)
);
GO