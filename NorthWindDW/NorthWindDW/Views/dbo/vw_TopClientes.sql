CREATE VIEW [dbo].[vw_TopClientes]
AS
SELECT
    dc.CompanyName,
    dc.Country,
    COUNT(DISTINCT f.OrderID) AS CantidadOrdenes,
    SUM(f.TotalVenta)         AS TotalComprado
FROM dbo.FactSales f
INNER JOIN dbo.DimCustomer dc ON f.CustomerSK = dc.CustomerSK
GROUP BY
    dc.CompanyName,
    dc.Country;
GO
