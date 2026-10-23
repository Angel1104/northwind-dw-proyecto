/*
  Validación independiente del reporte NorthWind.
  Ejecutar sobre la misma base NorthWindDW que alimenta Power BI.
  No modifica datos.
*/

SET NOCOUNT ON;

-- 1. Totales generales esperados en las tarjetas.
SELECT
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    SUM(CAST(f.Quantity AS bigint)) AS Unidades,
    COUNT(DISTINCT f.OrderID) AS Pedidos,
    CAST(
        SUM(CAST(f.TotalVenta AS decimal(19, 4)))
        / NULLIF(COUNT(DISTINCT f.OrderID), 0)
        AS decimal(19, 2)
    ) AS TicketPromedio,
    CAST(SUM(CAST(f.Quantity AS decimal(19, 4)) * CAST(f.UnitPrice AS decimal(19, 4))) AS decimal(19, 2)) AS VentasBrutas,
    CAST(
        SUM(CAST(f.Quantity AS decimal(19, 4)) * CAST(f.UnitPrice AS decimal(19, 4)))
        - SUM(CAST(f.TotalVenta AS decimal(19, 4)))
        AS decimal(19, 2)
    ) AS DescuentoMonetario
FROM dbo.FactSales AS f;

-- 2. Contraste anual. También revela si el último año es parcial.
SELECT
    d.CalendarYear,
    MIN(d.FullDate) AS PrimeraFecha,
    MAX(d.FullDate) AS UltimaFecha,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    SUM(CAST(f.Quantity AS bigint)) AS Unidades,
    COUNT(DISTINCT f.OrderID) AS Pedidos,
    CAST(
        SUM(CAST(f.TotalVenta AS decimal(19, 4)))
        / NULLIF(COUNT(DISTINCT f.OrderID), 0)
        AS decimal(19, 2)
    ) AS TicketPromedio
FROM dbo.FactSales AS f
INNER JOIN dbo.DimDate AS d
    ON d.DateKey = f.OrderDateKey
WHERE d.DateKey <> 0
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;

-- 3. Ventas mensuales, con año y número de mes para validar el eje temporal.
SELECT
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.MonthName,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    COUNT(DISTINCT f.OrderID) AS Pedidos
FROM dbo.FactSales AS f
INNER JOIN dbo.DimDate AS d
    ON d.DateKey = f.OrderDateKey
WHERE d.DateKey <> 0
GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.MonthName
ORDER BY d.CalendarYear, d.MonthNumberOfYear;

-- 4. Contraste por categoría. Elegir una fila y aplicar el mismo filtro en PBI.
SELECT
    p.CategoryName,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    SUM(CAST(f.Quantity AS bigint)) AS Unidades,
    COUNT(DISTINCT f.OrderID) AS Pedidos
FROM dbo.FactSales AS f
INNER JOIN dbo.DimProduct AS p
    ON p.ProductSK = f.ProductSK
GROUP BY p.CategoryName
ORDER BY VentasNetas DESC, p.CategoryName;

-- 5. Top 10 productos con la misma regla del visual.
SELECT TOP (10)
    p.ProductName,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    COUNT(DISTINCT f.OrderID) AS Pedidos
FROM dbo.FactSales AS f
INNER JOIN dbo.DimProduct AS p
    ON p.ProductSK = f.ProductSK
GROUP BY p.ProductName
ORDER BY VentasNetas DESC, p.ProductName;

-- 6. Top 10 clientes.
SELECT TOP (10)
    c.CompanyName,
    c.Country,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    COUNT(DISTINCT f.OrderID) AS Pedidos
FROM dbo.FactSales AS f
INNER JOIN dbo.DimCustomer AS c
    ON c.CustomerSK = f.CustomerSK
GROUP BY c.CompanyName, c.Country
ORDER BY VentasNetas DESC, c.CompanyName;

-- 7. Ventas, pedidos y ticket correcto por empleado.
SELECT
    CONCAT(e.FirstName, ' ', e.LastName) AS Empleado,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    COUNT(DISTINCT f.OrderID) AS Pedidos,
    CAST(
        SUM(CAST(f.TotalVenta AS decimal(19, 4)))
        / NULLIF(COUNT(DISTINCT f.OrderID), 0)
        AS decimal(19, 2)
    ) AS TicketPromedio
FROM dbo.FactSales AS f
INNER JOIN dbo.DimEmployee AS e
    ON e.EmployeeSK = f.EmployeeSK
GROUP BY e.FirstName, e.LastName
ORDER BY VentasNetas DESC, Empleado;

-- 8. El país comercial es el del cliente, no el país del proveedor.
SELECT
    c.Country,
    CAST(SUM(CAST(f.TotalVenta AS decimal(19, 4))) AS decimal(19, 2)) AS VentasNetas,
    COUNT(DISTINCT f.OrderID) AS Pedidos
FROM dbo.FactSales AS f
INNER JOIN dbo.DimCustomer AS c
    ON c.CustomerSK = f.CustomerSK
GROUP BY c.Country
ORDER BY VentasNetas DESC, c.Country;

-- 9. Calidad: el grano debe ser único.
SELECT f.OrderID, f.ProductID, COUNT_BIG(*) AS Repeticiones
FROM dbo.FactSales AS f
GROUP BY f.OrderID, f.ProductID
HAVING COUNT_BIG(*) > 1;

-- 10. Calidad: claves huérfanas. Todos los conteos deben ser cero.
SELECT
    SUM(CASE WHEN c.CustomerSK IS NULL THEN 1 ELSE 0 END) AS CustomerHuerfano,
    SUM(CASE WHEN p.ProductSK IS NULL THEN 1 ELSE 0 END) AS ProductHuerfano,
    SUM(CASE WHEN e.EmployeeSK IS NULL AND f.EmployeeSK IS NOT NULL THEN 1 ELSE 0 END) AS EmployeeHuerfano,
    SUM(CASE WHEN s.ShipperSK IS NULL AND f.ShipperSK IS NOT NULL THEN 1 ELSE 0 END) AS ShipperHuerfano,
    SUM(CASE WHEN od.DateKey IS NULL THEN 1 ELSE 0 END) AS OrderDateHuerfana,
    SUM(CASE WHEN rd.DateKey IS NULL THEN 1 ELSE 0 END) AS RequiredDateHuerfana,
    SUM(CASE WHEN sd.DateKey IS NULL AND f.ShippedDateKey IS NOT NULL THEN 1 ELSE 0 END) AS ShippedDateHuerfana
FROM dbo.FactSales AS f
LEFT JOIN dbo.DimCustomer AS c ON c.CustomerSK = f.CustomerSK
LEFT JOIN dbo.DimProduct AS p ON p.ProductSK = f.ProductSK
LEFT JOIN dbo.DimEmployee AS e ON e.EmployeeSK = f.EmployeeSK
LEFT JOIN dbo.DimShipper AS s ON s.ShipperSK = f.ShipperSK
LEFT JOIN dbo.DimDate AS od ON od.DateKey = f.OrderDateKey
LEFT JOIN dbo.DimDate AS rd ON rd.DateKey = f.RequiredDateKey
LEFT JOIN dbo.DimDate AS sd ON sd.DateKey = f.ShippedDateKey;

-- 11. Fechas desconocidas. No filtrar ventas por ShippedDate desconocida.
SELECT
    SUM(CASE WHEN f.OrderDateKey = 0 THEN 1 ELSE 0 END) AS LineasOrderDateDesconocida,
    SUM(CASE WHEN f.RequiredDateKey = 0 THEN 1 ELSE 0 END) AS LineasRequiredDateDesconocida,
    SUM(CASE WHEN f.ShippedDateKey = 0 OR f.ShippedDateKey IS NULL THEN 1 ELSE 0 END) AS LineasShippedDateDesconocida
FROM dbo.FactSales AS f;

SELECT *
FROM dbo.DimDate
WHERE DateKey = 0;

-- 12. Flete prorrateado: suma por pedido y suma global para contrastar con OLTP.
SELECT
    f.OrderID,
    CAST(SUM(CAST(f.Freight AS decimal(19, 4))) AS decimal(19, 2)) AS FreightPedido,
    COUNT_BIG(*) AS Lineas
FROM dbo.FactSales AS f
GROUP BY f.OrderID
ORDER BY f.OrderID;

SELECT CAST(SUM(CAST(f.Freight AS decimal(19, 4))) AS decimal(19, 2)) AS FreightTotal
FROM dbo.FactSales AS f;

