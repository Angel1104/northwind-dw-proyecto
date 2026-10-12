CREATE VIEW [dbo].[Category Sales For 1997]
AS
SELECT
    [Product Sales For 1997].CategoryName,
    SUM([Product Sales For 1997].ProductSales) AS CategorySales
FROM [Product Sales For 1997]
GROUP BY [Product Sales For 1997].CategoryName;
GO
