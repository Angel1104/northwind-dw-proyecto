CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    WITH EmployeeWithTerritory AS (
        SELECT
            e.[EmployeeID],
            e.[LastName],
            e.[FirstName],
            e.[Title],
            e.[TitleOfCourtesy],
            e.[BirthDate],
            e.[HireDate],
            e.[Address],
            e.[City],
            e.[Region],
            e.[PostalCode],
            e.[Country],
            e.[HomePhone],
            e.[Extension],
            e.[Notes],
            e.[ReportsTo],
            et.[TerritoryID],
            t.[TerritoryDescription],
            r.[RegionID],
            r.[RegionDescription],
            ROW_NUMBER() OVER (PARTITION BY e.[EmployeeID] ORDER BY et.[TerritoryID]) AS rn
        FROM [dbo].[Employees] e
        LEFT JOIN [dbo].[EmployeeTerritories] et ON e.EmployeeID = et.EmployeeID
        LEFT JOIN [dbo].[Territories] t ON et.TerritoryID = t.TerritoryID
        LEFT JOIN [dbo].[Region] r ON t.RegionID = r.RegionID
        WHERE
            (e.[rowversion] > CONVERT(ROWVERSION, @startRow) AND e.[rowversion] <= CONVERT(ROWVERSION, @endRow))
            OR (et.[rowversion] > CONVERT(ROWVERSION, @startRow) AND et.[rowversion] <= CONVERT(ROWVERSION, @endRow))
            OR (t.[rowversion] > CONVERT(ROWVERSION, @startRow) AND t.[rowversion] <= CONVERT(ROWVERSION, @endRow))
            OR (r.[rowversion] > CONVERT(ROWVERSION, @startRow) AND r.[rowversion] <= CONVERT(ROWVERSION, @endRow))
    )
    SELECT
        [EmployeeID], [LastName], [FirstName], [Title], [TitleOfCourtesy],
        [BirthDate], [HireDate], [Address], [City], [Region], [PostalCode],
        [Country], [HomePhone], [Extension], [Notes], [ReportsTo],
        [TerritoryID], [TerritoryDescription], [RegionID], [RegionDescription]
    FROM EmployeeWithTerritory
    WHERE rn = 1;
END
GO
