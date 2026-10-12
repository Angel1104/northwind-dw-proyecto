CREATE VIEW [dbo].[Products By Category]
AS
SELECT
    Categories.CategoryName,
    Products.ProductName,
    Products.QuantityPerUnit,
    Products.UnitsInStock,
    Products.Discontinued
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued <> 1;
GO
