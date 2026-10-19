CREATE TABLE [staging].[sales]
(
    [OrderID]        INT       NOT NULL,
    [ProductID]      INT       NOT NULL,
    [OrderDateKey]   INT       NOT NULL,
    [RequiredDateKey] INT      NOT NULL,
    [ShippedDateKey] INT       NULL,
    [CustomerSK]     INT       NOT NULL,
    [ProductSK]      INT       NOT NULL,
    [EmployeeSK]     INT       NULL,
    [ShipperSK]      INT       NULL,
    [Quantity]       SMALLINT  NOT NULL,
    [UnitPrice]      MONEY     NOT NULL,
    [Discount]       REAL      NOT NULL,
    [TotalVenta]     MONEY     NOT NULL,
    [Freight]        MONEY     NULL
);
GO
