CREATE VIEW [dbo].[Sales Totals By Amount]
AS
SELECT
    [Order Subtotals].Subtotal AS SaleAmount,
    Orders.OrderID,
    Customers.CompanyName,
    Orders.ShippedDate
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN [Order Subtotals] ON Orders.OrderID = [Order Subtotals].OrderID
WHERE [Order Subtotals].Subtotal > 2500
  AND Orders.ShippedDate BETWEEN '19970101' AND '19971231';
GO
