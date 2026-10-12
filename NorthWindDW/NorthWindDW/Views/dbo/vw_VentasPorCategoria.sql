CREATE VIEW [dbo].[vw_VentasPorCategoria]
AS
SELECT
    dp.CategoryName,
    dp.Country          AS SupplierCountry,
    dd.CalendarYear      AS Anio,
    SUM(f.Quantity)      AS UnidadesVendidas,
    SUM(f.TotalVenta)    AS TotalVentas
FROM dbo.FactSales f
INNER JOIN dbo.DimProduct dp ON f.ProductSK = dp.ProductSK
INNER JOIN dbo.DimDate dd    ON f.OrderDateKey = dd.DateKey
GROUP BY
    dp.CategoryName,
    dp.Country,
    dd.CalendarYear;
GO
