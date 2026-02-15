USE [MoneyMattersDb];
GO

-- SET IDENTITY_INSERT dbo.Currencies OFF; 
-- Ensure identity insertion is off if it was accidentally turned on

-- =================================================================
-- Currencies: USD, INR, JPY
-- =================================================================

INSERT INTO dbo.Currencies (Symbol, Name, CurrencyCode)
VALUES
    -- United States Dollar (USD)
    (N'$', 'US Dollar', 'USD'),
    
    -- Indian Rupee (INR)
    (N'₹', 'Indian Rupee', 'INR'),
    
    -- Japanese Yen (JPY)
    (N'¥', 'Japanese Yen', 'JPY');
GO
