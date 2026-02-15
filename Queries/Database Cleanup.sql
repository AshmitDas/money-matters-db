USE MoneyMattersDb;
GO


IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions
GO

IF OBJECT_ID('dbo.Currencies', 'U') IS NOT NULL DROP TABLE dbo.Currencies
GO

IF OBJECT_ID('dbo.Banks', 'U') IS NOT NULL DROP TABLE dbo.Banks;
GO

IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL DROP TABLE dbo.Accounts
GO

IF OBJECT_ID('dbo.TransactionSubtypes', 'U') IS NOT NULL DROP TABLE dbo.TransactionSubtypes
GO

IF OBJECT_ID('dbo.TransactionTypes', 'U') IS NOT NULL DROP TABLE dbo.TransactionTypes
GO

IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users
GO