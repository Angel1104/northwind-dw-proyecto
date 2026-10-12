CREATE PROCEDURE [dbo].[EmployeeSalesByCountry]
    @Beginning_Date DateTime,
    @Ending_Date DateTime
AS
SELECT Employees.Country, Employees.LastName, Employees.FirstName,
       Orders.ShippedDate, Orders.OrderID, [Order Subtotals].Subtotal AS SaleAmount
FROM Employees INNER JOIN
    (Orders INNER JOIN [Order Subtotals] ON Orders.OrderID = [Order Subtotals].OrderID)
    ON Employees.EmployeeID = Orders.EmployeeID
WHERE Orders.ShippedDate BETWEEN @Beginning_Date AND @Ending_Date
GO