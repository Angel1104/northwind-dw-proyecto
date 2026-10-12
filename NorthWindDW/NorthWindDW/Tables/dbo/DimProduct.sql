CREATE TABLE [dbo].[DimProduct]
(
    [ProductSK]        INT IDENTITY(1,1) NOT NULL,   -- SK
    [ProductID]         INT               NOT NULL,   -- clave natural
    [ProductName]       NVARCHAR(40)      NOT NULL,
    [QuantityPerUnit]   NVARCHAR(20)      NULL,
    [UnitPrice]         MONEY             NULL,
    [UnitsInStock]      SMALLINT          NULL,
    [UnitsOnOrder]      SMALLINT          NULL,
    [ReorderLevel]      SMALLINT          NULL,
    [Discontinued]      BIT               NOT NULL,
    [CategoryID]        INT               NULL,       -- de Categories
    [CategoryName]      NVARCHAR(15)      NOT NULL,
    [Description]       NVARCHAR(MAX)     NULL,
    [SupplierID]        INT               NULL,       -- de Suppliers
    [CompanyName]   NVARCHAR(40)      NULL,
    [ContactName]   NVARCHAR(30)      NULL,
    [Country]   NVARCHAR(15)      NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY ([ProductSK] ASC)
);