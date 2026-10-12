CREATE VIEW [dbo].[Order Subtotals]
AS
SELECT
    [OrderDetails].OrderID,
    SUM(CONVERT(MONEY, ([OrderDetails].UnitPrice * Quantity * (1 - Discount) / 100)) * 100) AS Subtotal
FROM [OrderDetails]
GROUP BY [OrderDetails].OrderID;
GO
