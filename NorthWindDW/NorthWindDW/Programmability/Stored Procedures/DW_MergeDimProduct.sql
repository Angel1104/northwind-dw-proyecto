CREATE PROCEDURE [dbo].[DW_MergeDimProduct]
AS
BEGIN

    UPDATE dp
    SET [ProductName]     = sp.[ProductName],
        [QuantityPerUnit] = sp.[QuantityPerUnit],
        [UnitPrice]       = sp.[UnitPrice],
        [UnitsInStock]    = sp.[UnitsInStock],
        [UnitsOnOrder]    = sp.[UnitsOnOrder],
        [ReorderLevel]    = sp.[ReorderLevel],
        [Discontinued]    = sp.[Discontinued],
        [CategoryID]      = sp.[CategoryID],
        [CategoryName]    = sp.[CategoryName],
        [Description]     = sp.[Description],
        [SupplierID]      = sp.[SupplierID],
        [CompanyName]     = sp.[CompanyName],
        [ContactName]     = sp.[ContactName],
        [Country]         = sp.[Country]
    FROM [dbo].[DimProduct]        dp
    INNER JOIN [staging].[product] sp ON (dp.[ProductSK] = sp.[ProductSK]);
END
GO
