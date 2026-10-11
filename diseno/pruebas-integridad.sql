-- Pruebas de integridad del modelo estrella NorthWindDW
-- Responsable: Angel Christian Flores Lazarte
--
-- Se ejecutan una vez que NorthWindOLTP (restaurada o creada por el
-- proyecto de Visual Studio) y NorthWindDW (con el ETL ya corrido) existen
-- en el mismo servidor. Cada bloque verifica una propiedad concreta del
-- diseño descrito en modelo-estrella.md: si alguna consulta devuelve una
-- fila, hay un problema que investigar.

USE NorthWindDW;
GO

-- ============================================================
-- Prueba 1: estructura del modelo (cantidad de tablas y llaves foraneas)
-- ============================================================
-- Se espera: 5 dimensiones + 1 tabla de hechos = 6 tablas en el esquema dbo
SELECT
    (SELECT COUNT(*) FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo') AS tablas_en_dbo,
    (SELECT COUNT(*) FROM sys.foreign_keys) AS llaves_foraneas;
-- Resultado esperado: 6 tablas, al menos 5 FK (una por dimension que
-- referencia FactSales; DimDate puede tener mas de una si se modela
-- con FKs independientes para cada fecha de negocio).


-- ============================================================
-- Prueba 2: no deben existir lineas de venta huerfanas
-- ============================================================
-- Una fila de FactSales es "huerfana" si su CustomerSK, ProductSK, etc.
-- no corresponde a ninguna fila real de su dimension. No deberia
-- devolver ninguna fila.
SELECT f.OrderID, f.ProductID, 'CustomerSK invalido' AS Problema
FROM dbo.FactSales f
LEFT JOIN dbo.DimCustomer dc ON f.CustomerSK = dc.CustomerSK
WHERE f.CustomerSK IS NOT NULL AND dc.CustomerSK IS NULL

UNION ALL

SELECT f.OrderID, f.ProductID, 'ProductSK invalido'
FROM dbo.FactSales f
LEFT JOIN dbo.DimProduct dp ON f.ProductSK = dp.ProductSK
WHERE f.ProductSK IS NOT NULL AND dp.ProductSK IS NULL

UNION ALL

SELECT f.OrderID, f.ProductID, 'OrderDateKey invalido'
FROM dbo.FactSales f
LEFT JOIN dbo.DimDate dd ON f.OrderDateKey = dd.DateKey
WHERE dd.DateKey IS NULL;


-- ============================================================
-- Prueba 3: coherencia de conteos entre OLTP y warehouse
-- ============================================================
-- La cantidad de filas de cada dimension deberia coincidir con la
-- cantidad de filas de su tabla de origen en el OLTP (asumiendo que el
-- ETL ya migro todos los registros).
SELECT
    (SELECT COUNT(*) FROM NorthWind.dbo.Customers) AS customers_oltp,
    (SELECT COUNT(*) FROM dbo.DimCustomer)         AS dimcustomer_dw;

SELECT
    (SELECT COUNT(*) FROM NorthWind.dbo.Products) AS products_oltp,
    (SELECT COUNT(*) FROM dbo.DimProduct)         AS dimproduct_dw;

SELECT
    (SELECT COUNT(*) FROM NorthWind.dbo.OrderDetails) AS lineas_orden_oltp,
    (SELECT COUNT(*) FROM dbo.FactSales)              AS lineas_fact_dw;


-- ============================================================
-- Prueba 4: la suma de ventas del warehouse coincide con el OLTP
-- ============================================================
-- El total de ingresos calculado directamente sobre el OLTP debe ser
-- igual (o muy cercano, por redondeo) al calculado sobre FactSales.
SELECT
    (SELECT SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) FROM NorthWind.dbo.OrderDetails od) AS total_ventas_oltp,
    (SELECT SUM(f.LineTotal) FROM dbo.FactSales f) AS total_ventas_dw;
