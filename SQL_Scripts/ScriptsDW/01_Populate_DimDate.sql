DECLARE @startdate DATE = '1996-07-04',
        @enddate   DATE = '1998-06-11';

;WITH Tally(n) AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1
    FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)
    CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
    CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
)
INSERT INTO dbo.DimDate(DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek,
    DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, [MonthName],
    MonthNumberOfYear, CalendarQuarter, CalendarYear, CalendarSemester)
SELECT
    CONVERT(INT, CONVERT(VARCHAR, dl.FullDate, 112)),
    dl.FullDate,
    DATEPART(dw, dl.FullDate),
    DATENAME(WEEKDAY, dl.FullDate),
    DATEPART(d, dl.FullDate),
    DATEPART(dy, dl.FullDate),
    DATEPART(wk, dl.FullDate),
    DATENAME(MONTH, dl.FullDate),
    MONTH(dl.FullDate),
    DATEPART(qq, dl.FullDate),
    YEAR(dl.FullDate),
    CASE DATEPART(qq, dl.FullDate) WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 2 WHEN 4 THEN 2 END
FROM (
    SELECT DATEADD(day, n, @startdate) AS FullDate
    FROM Tally
    WHERE DATEADD(day, n, @startdate) <= @enddate
) dl
LEFT JOIN dbo.DimDate dd ON dl.FullDate = dd.FullDate
WHERE dd.FullDate IS NULL;
IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'Customer')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion]) VALUES ('Customer', 0)
END
GO

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'Product')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion]) VALUES ('Product', 0)
END
GO

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'Employee')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion]) VALUES ('Employee', 0)
END
GO

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'Shipper')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion]) VALUES ('Shipper', 0)
END
GO

IF NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[PackageConfig] WHERE [TableName] = 'Sales')
BEGIN
    INSERT [dbo].[PackageConfig] ([TableName], [LastRowVersion]) VALUES ('Sales', 0)
END
GO
