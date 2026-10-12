CREATE VIEW [dbo].[Alphabetical List Of Products]
AS
SELECT Products.*, Categories.CategoryName
FROM Categories
INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued = 0;
GO
