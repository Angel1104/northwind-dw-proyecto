/*
  Carga local reproducible para desarrollar el reporte Power BI.

  Requisitos:
  - NorthWindOLTP contiene el respaldo NorthWind.bak entregado con la tarea.
  - NorthWindDW contiene las seis tablas definidas por este repositorio.

  Esta carga no reemplaza ni modifica los paquetes SSIS del grupo. Se usa
  únicamente como alternativa local cuando el DW/SSAS del equipo no es
  accesible.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

USE [NorthWindDW];

BEGIN TRANSACTION;

DELETE FROM dbo.FactSales;
DELETE FROM dbo.DimCustomer;
DELETE FROM dbo.DimEmployee;
DELETE FROM dbo.DimProduct;
DELETE FROM dbo.DimShipper;
DELETE FROM dbo.DimDate;

DBCC CHECKIDENT ('dbo.DimCustomer', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.DimEmployee', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.DimProduct', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.DimShipper', RESEED, 0) WITH NO_INFOMSGS;

-- La fila 0 representa una fecha desconocida y no actividad real.
INSERT dbo.DimDate
(
    DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek,
    DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
    MonthName, MonthNumberOfYear, CalendarQuarter,
    CalendarYear, CalendarSemester
)
VALUES
(
    0, CONVERT(date, '19000101', 112), 0, N'N/A',
    0, 0, 0, N'N/A', 0, 0, 0, 0
);

DECLARE @StartDate date;
DECLARE @EndDate date;

SELECT
    @StartDate = MIN(DateValue),
    @EndDate = MAX(DateValue)
FROM
(
    SELECT MIN(OrderDate) AS DateValue FROM NorthWindOLTP.dbo.Orders
    UNION ALL
    SELECT MAX(OrderDate) FROM NorthWindOLTP.dbo.Orders
    UNION ALL
    SELECT MIN(RequiredDate) FROM NorthWindOLTP.dbo.Orders
    UNION ALL
    SELECT MAX(RequiredDate) FROM NorthWindOLTP.dbo.Orders
    UNION ALL
    SELECT MIN(ShippedDate) FROM NorthWindOLTP.dbo.Orders
    UNION ALL
    SELECT MAX(ShippedDate) FROM NorthWindOLTP.dbo.Orders
) AS DateBounds
WHERE DateValue IS NOT NULL;

;WITH N AS
(
    SELECT TOP (DATEDIFF(day, @StartDate, @EndDate) + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
), Dates AS
(
    SELECT DATEADD(day, n, @StartDate) AS FullDate
    FROM N
)
INSERT dbo.DimDate
(
    DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek,
    DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
    MonthName, MonthNumberOfYear, CalendarQuarter,
    CalendarYear, CalendarSemester
)
SELECT
    CONVERT(int, CONVERT(char(8), FullDate, 112)),
    FullDate,
    DATEPART(weekday, FullDate),
    DATENAME(weekday, FullDate),
    DATEPART(day, FullDate),
    DATEPART(dayofyear, FullDate),
    DATEPART(week, FullDate),
    DATENAME(month, FullDate),
    DATEPART(month, FullDate),
    DATEPART(quarter, FullDate),
    DATEPART(year, FullDate),
    CASE WHEN DATEPART(quarter, FullDate) <= 2 THEN 1 ELSE 2 END
FROM Dates;

INSERT dbo.DimCustomer
(
    CustomerID, CompanyName, ContactName, ContactTitle, Address,
    City, Region, PostalCode, Country, Phone, Fax,
    CustomerTypeID, CustomerDesc
)
SELECT
    c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address,
    c.City, c.Region, c.PostalCode, c.Country, c.Phone, c.Fax,
    ccd.CustomerTypeID, cd.CustomerDesc
FROM NorthWindOLTP.dbo.Customers AS c
LEFT JOIN NorthWindOLTP.dbo.CustomerCustomerDemo AS ccd
    ON ccd.CustomerID = c.CustomerID
LEFT JOIN NorthWindOLTP.dbo.CustomerDemographics AS cd
    ON cd.CustomerTypeID = ccd.CustomerTypeID;

-- El modelo físico admite un solo territorio por empleado. Se usa el primero
-- por TerritoryID, la misma regla propuesta en el PR #6 aún no fusionado.
INSERT dbo.DimEmployee
(
    EmployeeID, LastName, FirstName, Title, TitleOfCourtesy,
    BirthDate, HireDate, Address, City, Region, PostalCode, Country,
    HomePhone, Extension, Notes, ReportsTo, TerritoryID,
    TerritoryDescription, RegionID, RegionDescription
)
SELECT
    e.EmployeeID, e.LastName, e.FirstName, e.Title, e.TitleOfCourtesy,
    e.BirthDate, e.HireDate, e.Address, e.City, e.Region, e.PostalCode,
    e.Country, e.HomePhone, e.Extension, e.Notes, e.ReportsTo,
    territory.TerritoryID, territory.TerritoryDescription,
    territory.RegionID, territory.RegionDescription
FROM NorthWindOLTP.dbo.Employees AS e
OUTER APPLY
(
    SELECT TOP (1)
        et.TerritoryID,
        t.TerritoryDescription,
        r.RegionID,
        r.RegionDescription
    FROM NorthWindOLTP.dbo.EmployeeTerritories AS et
    INNER JOIN NorthWindOLTP.dbo.Territories AS t
        ON t.TerritoryID = et.TerritoryID
    INNER JOIN NorthWindOLTP.dbo.Region AS r
        ON r.RegionID = t.RegionID
    WHERE et.EmployeeID = e.EmployeeID
    ORDER BY et.TerritoryID
) AS territory;

INSERT dbo.DimProduct
(
    ProductID, ProductName, QuantityPerUnit, UnitPrice,
    UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued,
    CategoryID, CategoryName, Description,
    SupplierID, CompanyName, ContactName, Country
)
SELECT
    p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice,
    p.UnitsInStock, p.UnitsOnOrder, p.ReorderLevel, p.Discontinued,
    c.CategoryID, c.CategoryName, c.Description,
    s.SupplierID, s.CompanyName, s.ContactName, s.Country
FROM NorthWindOLTP.dbo.Products AS p
INNER JOIN NorthWindOLTP.dbo.Categories AS c
    ON c.CategoryID = p.CategoryID
INNER JOIN NorthWindOLTP.dbo.Suppliers AS s
    ON s.SupplierID = p.SupplierID;

INSERT dbo.DimShipper (ShipperID, CompanyName, Phone)
SELECT ShipperID, CompanyName, Phone
FROM NorthWindOLTP.dbo.Shippers;

;WITH SalesSource AS
(
    SELECT
        o.OrderID,
        od.ProductID,
        o.OrderDate,
        o.RequiredDate,
        o.ShippedDate,
        o.CustomerID,
        o.EmployeeID,
        o.ShipVia,
        od.Quantity,
        od.UnitPrice,
        od.Discount,
        CAST(od.Quantity * od.UnitPrice * (1 - od.Discount) AS money) AS TotalVenta,
        CAST(o.Freight AS decimal(19, 4))
            / NULLIF(COUNT_BIG(*) OVER (PARTITION BY o.OrderID), 0) AS FreightRaw,
        ROW_NUMBER() OVER (PARTITION BY o.OrderID ORDER BY od.ProductID) AS rn,
        COUNT_BIG(*) OVER (PARTITION BY o.OrderID) AS LineCount
    FROM NorthWindOLTP.dbo.Orders AS o
    INNER JOIN NorthWindOLTP.dbo.OrderDetails AS od
        ON od.OrderID = o.OrderID
), SalesWithFreight AS
(
    SELECT
        *,
        CAST(
            CASE
                WHEN rn = LineCount THEN
                    ROUND(FreightRaw, 2)
                    + ROUND(SUM(FreightRaw) OVER (PARTITION BY OrderID), 2)
                    - SUM(ROUND(FreightRaw, 2)) OVER (PARTITION BY OrderID)
                ELSE ROUND(FreightRaw, 2)
            END
            AS money
        ) AS FreightAllocated
    FROM SalesSource
)
INSERT dbo.FactSales
(
    OrderID, ProductID, OrderDateKey, RequiredDateKey, ShippedDateKey,
    CustomerSK, ProductSK, EmployeeSK, ShipperSK,
    Quantity, UnitPrice, Discount, TotalVenta, Freight
)
SELECT
    s.OrderID,
    s.ProductID,
    CONVERT(int, CONVERT(char(8), s.OrderDate, 112)),
    COALESCE(CONVERT(int, CONVERT(char(8), s.RequiredDate, 112)), 0),
    COALESCE(CONVERT(int, CONVERT(char(8), s.ShippedDate, 112)), 0),
    c.CustomerSK,
    p.ProductSK,
    e.EmployeeSK,
    sh.ShipperSK,
    s.Quantity,
    s.UnitPrice,
    s.Discount,
    s.TotalVenta,
    s.FreightAllocated
FROM SalesWithFreight AS s
INNER JOIN dbo.DimCustomer AS c
    -- El respaldo entregado usa Modern_Spanish_CI_AS y el DW del repositorio
    -- usa SQL_Latin1_General_CP1_CI_AS.
    ON c.CustomerID = s.CustomerID COLLATE DATABASE_DEFAULT
INNER JOIN dbo.DimProduct AS p
    ON p.ProductID = s.ProductID
LEFT JOIN dbo.DimEmployee AS e
    ON e.EmployeeID = s.EmployeeID
LEFT JOIN dbo.DimShipper AS sh
    ON sh.ShipperID = s.ShipVia;

COMMIT TRANSACTION;

SELECT 'DimCustomer' AS Tabla, COUNT_BIG(*) AS Filas FROM dbo.DimCustomer
UNION ALL SELECT 'DimDate', COUNT_BIG(*) FROM dbo.DimDate
UNION ALL SELECT 'DimEmployee', COUNT_BIG(*) FROM dbo.DimEmployee
UNION ALL SELECT 'DimProduct', COUNT_BIG(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimShipper', COUNT_BIG(*) FROM dbo.DimShipper
UNION ALL SELECT 'FactSales', COUNT_BIG(*) FROM dbo.FactSales;

