CREATE PROCEDURE [dbo].[TenMostExpensiveProducts]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        Products.ProductName AS TenMostExpensiveProducts,
        Products.UnitPrice
    FROM Products
    ORDER BY Products.UnitPrice DESC;
END
GO
