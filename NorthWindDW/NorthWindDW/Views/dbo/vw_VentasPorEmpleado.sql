CREATE VIEW [dbo].[vw_VentasPorEmpleado]
AS
SELECT
    de.FirstName,
    de.LastName,
    de.Title,
    COUNT(DISTINCT f.OrderID) AS CantidadOrdenes,
    SUM(f.TotalVenta)         AS TotalVentas,
    AVG(f.TotalVenta)         AS TicketPromedio
FROM dbo.FactSales f
INNER JOIN dbo.DimEmployee de ON f.EmployeeSK = de.EmployeeSK
GROUP BY
    de.FirstName,
    de.LastName,
    de.Title;
GO
