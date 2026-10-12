CREATE PROCEDURE [dbo].[SalesByYear]
    @Beginning_Date DATETIME,
    @Ending_Date DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Orders.ShippedDate,
        Orders.OrderID,
        [Order Subtotals].Subtotal,
        DATENAME(yy, ShippedDate) AS Year
    FROM Orders
    INNER JOIN [Order Subtotals] ON Orders.OrderID = [Order Subtotals].OrderID
    WHERE Orders.ShippedDate BETWEEN @Beginning_Date AND @Ending_Date;
END
GO
