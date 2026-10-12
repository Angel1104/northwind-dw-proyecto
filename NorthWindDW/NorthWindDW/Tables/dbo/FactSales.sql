CREATE TABLE [dbo].[FactSales]
(
    -- Claves naturales (PK compuesta)
    [OrderID]           INT         NOT NULL,
    [ProductID]         INT         NOT NULL,

    -- Claves foráneas a dimensiones
    [OrderDateKey]      INT         NOT NULL,  -- FK -> DimDate (OrderDate)
    [RequiredDateKey]   INT         NOT NULL,  -- FK -> DimDate
    [ShippedDateKey]    INT         NULL,      -- FK -> DimDate
    [CustomerSK]        INT         NOT NULL,  -- FK -> DimCustomer
    [ProductSK]         INT         NOT NULL,  -- FK -> DimProduct
    [EmployeeSK]        INT         NULL,      -- FK -> DimEmployee
    [ShipperSK]         INT         NULL,      -- FK -> DimShipper

    -- Medidas de OrderDetails
    [Quantity]          SMALLINT    NOT NULL,
    [UnitPrice]         MONEY       NOT NULL,
    [Discount]          REAL        NOT NULL,
    [TotalVenta]        MONEY       NOT NULL,  -- Quantity * UnitPrice * (1 - Discount)

    -- Medida de Orders
    [Freight]           MONEY       NULL,

    -- Clave primaria compuesta
    CONSTRAINT [PK_FactSales]
        PRIMARY KEY ([OrderID] ASC, [ProductID] ASC),

    -- Claves foráneas a DimDate
    CONSTRAINT [FK_FactSales_DimDate_Order]
        FOREIGN KEY ([OrderDateKey])
        REFERENCES [dbo].[DimDate] ([DateKey]),

    CONSTRAINT [FK_FactSales_DimDate_Required]
        FOREIGN KEY ([RequiredDateKey])
        REFERENCES [dbo].[DimDate] ([DateKey]),

    CONSTRAINT [FK_FactSales_DimDate_Shipped]
        FOREIGN KEY ([ShippedDateKey])
        REFERENCES [dbo].[DimDate] ([DateKey]),

    -- Claves foráneas a dimensiones
    CONSTRAINT [FK_FactSales_DimCustomer]
        FOREIGN KEY ([CustomerSK])
        REFERENCES [dbo].[DimCustomer] ([CustomerSK]),

    CONSTRAINT [FK_FactSales_DimProduct]
        FOREIGN KEY ([ProductSK])
        REFERENCES [dbo].[DimProduct] ([ProductSK]),

    CONSTRAINT [FK_FactSales_DimEmployee]
        FOREIGN KEY ([EmployeeSK])
        REFERENCES [dbo].[DimEmployee] ([EmployeeSK]),

    CONSTRAINT [FK_FactSales_DimShipper]
        FOREIGN KEY ([ShipperSK])
        REFERENCES [dbo].[DimShipper] ([ShipperSK])
);
GO