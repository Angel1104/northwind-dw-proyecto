CREATE VIEW [dbo].[Product Sales For 1997]
AS
SELECT
    Categories.CategoryName,
    Products.ProductName,
    SUM(CONVERT(MONEY, ([OrderDetails].UnitPrice * [OrderDetails].Quantity * (1 - [OrderDetails].Discount) / 100)) * 100) AS ProductSales
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
INNER JOIN [OrderDetails] ON Products.ProductID = [OrderDetails].ProductID
INNER JOIN Orders ON Orders.OrderID = [OrderDetails].OrderID
WHERE Orders.ShippedDate BETWEEN '19970101' AND '19971231'
GROUP BY Categories.CategoryName, Products.ProductName;
GO
