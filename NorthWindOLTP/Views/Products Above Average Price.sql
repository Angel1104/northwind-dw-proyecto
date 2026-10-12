CREATE VIEW [dbo].[Products Above Average Price]
AS
SELECT
    Products.ProductName,
    Products.UnitPrice
FROM Products
WHERE Products.UnitPrice > (SELECT AVG(UnitPrice) FROM Products);
GO
