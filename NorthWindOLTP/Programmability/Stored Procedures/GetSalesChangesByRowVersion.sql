CREATE PROCEDURE [dbo].[GetSalesChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Prorrateo del Freight con método del residuo
    WITH FleteProrrateado AS (
        SELECT
            od.OrderID,
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
            -- TotalVenta: Quantity * UnitPrice * (1 - Discount)
            od.Quantity * od.UnitPrice * (1 - od.Discount) AS TotalVenta,
            -- Prorrateo del freight
            o.Freight / COUNT(*) OVER (PARTITION BY od.OrderID) AS FleteBruto,
            ROW_NUMBER() OVER (PARTITION BY od.OrderID ORDER BY od.ProductID) AS rn,
            COUNT(*) OVER (PARTITION BY od.OrderID) AS TotalLineas
        FROM [OrderDetails] od
        INNER JOIN [Orders] o ON od.OrderID = o.OrderID
        WHERE
            (o.[rowversion] > CONVERT(ROWVERSION, @startRow) AND o.[rowversion] <= CONVERT(ROWVERSION, @endRow))
            OR (od.[rowversion] > CONVERT(ROWVERSION, @startRow) AND od.[rowversion] <= CONVERT(ROWVERSION, @endRow))
    )
    -- 2. Selección final con DateKeys y ajuste del residuo
    SELECT
        OrderID,
        ProductID,
        -- OrderDateKey: YYYYMMDD
        OrderDateKey = CONVERT(INT,
            (CONVERT(CHAR(4), DATEPART(YEAR, OrderDate))
           + CASE WHEN DATEPART(MONTH, OrderDate) < 10
                  THEN '0' + CONVERT(CHAR(1), DATEPART(MONTH, OrderDate))
                  ELSE CONVERT(CHAR(2), DATEPART(MONTH, OrderDate))
             END
           + CASE WHEN DATEPART(DAY, OrderDate) < 10
                  THEN '0' + CONVERT(CHAR(1), DATEPART(DAY, OrderDate))
                  ELSE CONVERT(CHAR(2), DATEPART(DAY, OrderDate))
             END)),
        -- RequiredDateKey: 0 si es NULL, YYYYMMDD si no
        RequiredDateKey = CASE
            WHEN RequiredDate IS NULL THEN 0
            ELSE CONVERT(INT,
                (CONVERT(CHAR(4), DATEPART(YEAR, RequiredDate))
               + CASE WHEN DATEPART(MONTH, RequiredDate) < 10
                      THEN '0' + CONVERT(CHAR(1), DATEPART(MONTH, RequiredDate))
                      ELSE CONVERT(CHAR(2), DATEPART(MONTH, RequiredDate))
                 END
               + CASE WHEN DATEPART(DAY, RequiredDate) < 10
                      THEN '0' + CONVERT(CHAR(1), DATEPART(DAY, RequiredDate))
                      ELSE CONVERT(CHAR(2), DATEPART(DAY, RequiredDate))
                 END))
        END,
        -- ShippedDateKey: 0 si es NULL, YYYYMMDD si no
        ShippedDateKey = CASE
            WHEN ShippedDate IS NULL THEN 0
            ELSE CONVERT(INT,
                (CONVERT(CHAR(4), DATEPART(YEAR, ShippedDate))
               + CASE WHEN DATEPART(MONTH, ShippedDate) < 10
                      THEN '0' + CONVERT(CHAR(1), DATEPART(MONTH, ShippedDate))
                      ELSE CONVERT(CHAR(2), DATEPART(MONTH, ShippedDate))
                 END
               + CASE WHEN DATEPART(DAY, ShippedDate) < 10
                      THEN '0' + CONVERT(CHAR(1), DATEPART(DAY, ShippedDate))
                      ELSE CONVERT(CHAR(2), DATEPART(DAY, ShippedDate))
                 END))
        END,
        CustomerID,
        -- ← ProductID duplicada ELIMINADA
        EmployeeID,
        ShipVia,
        Quantity,
        UnitPrice,
        Discount,
        TotalVenta,
        -- Freight con ajuste del residuo en la última línea
        CASE
            WHEN rn = TotalLineas
                THEN ROUND(FleteBruto, 2)
                     + (ROUND(SUM(FleteBruto) OVER (PARTITION BY OrderID), 2)
                        - SUM(ROUND(FleteBruto, 2)) OVER (PARTITION BY OrderID))
            ELSE ROUND(FleteBruto, 2)
        END AS Freight
    FROM FleteProrrateado;
END
GO
