CREATE TABLE [staging].[product]
(
    [ProductSK]        INT           NOT NULL,
    [ProductID]        INT           NOT NULL,  
    [ProductName]      NVARCHAR(40)  NOT NULL,
    [QuantityPerUnit]  NVARCHAR(20)  NULL,
    [UnitPrice]        MONEY         NULL,
    [UnitsInStock]     SMALLINT      NULL,
    [UnitsOnOrder]     SMALLINT      NULL,
    [ReorderLevel]     SMALLINT      NULL,
    [Discontinued]     BIT           NOT NULL,
    [CategoryID]       INT           NULL,     
    [CategoryName]     NVARCHAR(15)  NOT NULL,
    [Description]      NVARCHAR(MAX) NULL,
    [SupplierID]       INT           NULL, 
    [CompanyName]      NVARCHAR(40)  NULL,
    [ContactName]      NVARCHAR(30)  NULL,
    [Country]          NVARCHAR(15)  NULL
);
GO
