CREATE VIEW [dbo].[Sales By Category]
AS
SELECT
    Categories.CategoryID,
    Categories.CategoryName,
    Products.ProductName,
    SUM([Order Details Extended].ExtendedPrice) AS ProductSales
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
INNER JOIN [Order Details Extended] ON Products.ProductID = [Order Details Extended].ProductID
INNER JOIN Orders ON Orders.OrderID = [Order Details Extended].OrderID
WHERE Orders.OrderDate BETWEEN '19970101' AND '19971231'
GROUP BY Categories.CategoryID, Categories.CategoryName, Products.ProductName;
GO