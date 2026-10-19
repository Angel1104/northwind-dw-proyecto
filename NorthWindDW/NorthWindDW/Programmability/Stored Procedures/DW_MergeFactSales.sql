CREATE PROCEDURE [dbo].[DW_MergeFactSales]
AS
BEGIN
    UPDATE fs
    SET [OrderDateKey]    = ss.[OrderDateKey],
        [RequiredDateKey] = ss.[RequiredDateKey],
        [ShippedDateKey]  = ss.[ShippedDateKey],
        [CustomerSK]      = ss.[CustomerSK],
        [ProductSK]       = ss.[ProductSK],
        [EmployeeSK]      = ss.[EmployeeSK],
        [ShipperSK]       = ss.[ShipperSK],
        [Quantity]        = ss.[Quantity],
        [UnitPrice]       = ss.[UnitPrice],
        [Discount]        = ss.[Discount],
        [TotalVenta]      = ss.[TotalVenta],
        [Freight]         = ss.[Freight]
    FROM [dbo].[FactSales]       fs
    INNER JOIN [staging].[sales] ss ON (fs.[OrderID]   = ss.[OrderID] AND fs.[ProductID] = ss.[ProductID]);
END
GO
