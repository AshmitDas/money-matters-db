-- Put the target database name
USE [MoneyMattersDb];
GO

-- =================================================================
-- 1. INSERT INTO dbo.TransactionTypes (Categories)
-- =================================================================
-- Insert all unique transaction types. The transactiontypeId will be auto-generated.

INSERT INTO dbo.TransactionTypes (Name)
VALUES
    ('INCOME'),
    ('HOUSING'),
    ('FOOD & DRINK'),
    ('TRANSPORTATION'),
    ('UTILITIES'),
    ('WELLNESS'),
    ('ENTERTAINMENT'),
    ('INVESTMENT'),
    ('DEBT'),
    ('TRAVEL'),
    ('HOBBIES'),
    ('MISCELLANEOUS'),
    ('WITHDRAWALS');
GO

-- =================================================================
-- 2. INSERT INTO dbo.TransactionSubtypes (Subcategories)
-- =================================================================
-- Insert all subtypes by joining the subtype data (T) with the newly inserted types (TT)
-- to look up the correct transactiontypeId.

WITH SubtypeData (TransactionTypeName, SubtypeName) AS
(
    -- Define all transaction type and subtype pairs
    SELECT 'INCOME', 'Salary/Wages' UNION ALL
    SELECT 'INCOME', 'Freelance/Consulting' UNION ALL
    SELECT 'INCOME', 'Investment Dividends' UNION ALL
    SELECT 'INCOME', 'Rental Income' UNION ALL
    SELECT 'INCOME', 'Gifts Received' UNION ALL

    SELECT 'HOUSING', 'Rent/Mortgage' UNION ALL
    SELECT 'HOUSING', 'Property Taxes' UNION ALL
    SELECT 'HOUSING', 'Home Repairs/Maintenance' UNION ALL
    SELECT 'HOUSING', 'HOA Fees' UNION ALL

    SELECT 'FOOD & DRINK', 'Groceries' UNION ALL
    SELECT 'FOOD & DRINK', 'Restaurants/Dining Out' UNION ALL
    SELECT 'FOOD & DRINK', 'Coffee/Cafes' UNION ALL
    SELECT 'FOOD & DRINK', 'Alcohol/Bars' UNION ALL

    SELECT 'TRANSPORTATION', 'Fuel/Gas' UNION ALL
    SELECT 'TRANSPORTATION', 'Public Transit' UNION ALL
    SELECT 'TRANSPORTATION', 'Ride Sharing' UNION ALL
    SELECT 'TRANSPORTATION', 'Car Insurance' UNION ALL
    SELECT 'TRANSPORTATION', 'Maintenance/Repairs' UNION ALL

    SELECT 'UTILITIES', 'Electricity' UNION ALL
    SELECT 'UTILITIES', 'Water & Sewage' UNION ALL
    SELECT 'UTILITIES', 'Internet/Cable' UNION ALL
    SELECT 'UTILITIES', 'Mobile Phone' UNION ALL

    SELECT 'WELLNESS', 'Gym/Fitness' UNION ALL
    SELECT 'WELLNESS', 'Healthcare/Doctor' UNION ALL
    SELECT 'WELLNESS', 'Pharmacy/Medication' UNION ALL
    SELECT 'WELLNESS', 'Hair/Beauty' UNION ALL

    SELECT 'ENTERTAINMENT', 'Subscriptions' UNION ALL
    SELECT 'ENTERTAINMENT', 'Concerts/Events' UNION ALL
    SELECT 'ENTERTAINMENT', 'Books/Media' UNION ALL

    SELECT 'INVESTMENT', 'Retirement Contribution' UNION ALL
    SELECT 'INVESTMENT', 'Stock/Mutual Fund Purchase' UNION ALL
    SELECT 'INVESTMENT', 'Cryptocurrency' UNION ALL
    SELECT 'INVESTMENT', 'Real Estate Investment' UNION ALL

    SELECT 'DEBT', 'Loan Payment' UNION ALL
    SELECT 'DEBT', 'Credit Card Payment' UNION ALL
    SELECT 'DEBT', 'Fees/Charges' UNION ALL
    SELECT 'DEBT', 'Interest Paid' UNION ALL

    SELECT 'TRAVEL', 'Airfare/Flights' UNION ALL
    SELECT 'TRAVEL', 'Accommodation/Hotels' UNION ALL
    SELECT 'TRAVEL', 'Railways' UNION ALL
    SELECT 'TRAVEL', 'Local Transit (Travel)' UNION ALL
    SELECT 'TRAVEL', 'Travel Insurance' UNION ALL
    SELECT 'TRAVEL', 'Vacation Rentals' UNION ALL

    SELECT 'HOBBIES', 'Sports Equipment/Gear' UNION ALL
    SELECT 'HOBBIES', 'Gaming' UNION ALL
    SELECT 'HOBBIES', 'Figurine' UNION ALL
    SELECT 'HOBBIES', 'Beyblades' UNION ALL
    SELECT 'HOBBIES', 'Diecast' UNION ALL
    SELECT 'HOBBIES', 'Trading Cards' UNION ALL
    SELECT 'HOBBIES', 'Comics/Manga' UNION ALL

    SELECT 'MISCELLANEOUS', 'Gifts Given' UNION ALL
    SELECT 'MISCELLANEOUS', 'Donations/Charity' UNION ALL
    SELECT 'MISCELLANEOUS', 'Postage/Shipping' UNION ALL
    SELECT 'MISCELLANEOUS', 'General Spending' UNION ALL

    SELECT 'WITHDRAWALS', 'ATM Cash Withdrawal' UNION ALL
    SELECT 'WITHDRAWALS', 'Cash Deposit/Transfer'
)
INSERT INTO dbo.TransactionSubtypes (transactiontypeId, Name)
SELECT
    TT.transactiontypeId,
    SD.SubtypeName
FROM
    SubtypeData SD
INNER JOIN
    dbo.TransactionTypes TT ON SD.TransactionTypeName = TT.Name;
GO
