CREATE PROCEDURE [dbo].[CustOrdersDetail] @OrderID int
AS
SELECT ProductName,
    UnitPrice = ROUND(Od.UnitPrice, 2),
    Quantity,
    Discount = CONVERT(int, Discount * 100),
    ExtendedPrice = ROUND(CONVERT(money, Quantity * (1 - Discount) * Od.UnitPrice), 2)
FROM Products P, [OrderDetails] Od
WHERE Od.ProductID = P.ProductID AND Od.OrderID = @OrderID
GO
