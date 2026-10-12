CREATE VIEW [dbo].[Customer And Suppliers By City]
AS
SELECT
    City,
    CompanyName,
    ContactName,
    'Customers' AS Relationship
FROM Customers

UNION

SELECT
    City,
    CompanyName,
    ContactName,
    'Suppliers' AS Relationship
FROM Suppliers;
GO
