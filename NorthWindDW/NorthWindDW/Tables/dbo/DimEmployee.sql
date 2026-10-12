CREATE TABLE [dbo].[DimEmployee]
(
    [EmployeeSK]        INT IDENTITY(1,1) NOT NULL,   -- SK
    [EmployeeID]         INT               NOT NULL,   -- clave natural
    [LastName]           NVARCHAR(20)      NOT NULL,
    [FirstName]          NVARCHAR(10)      NOT NULL,
    [Title]              NVARCHAR(30)      NULL,
    [TitleOfCourtesy]    NVARCHAR(25)      NULL,
    [BirthDate]          DATETIME          NULL,
    [HireDate]           DATETIME          NULL,
    [Address]            NVARCHAR(60)      NULL,
    [City]               NVARCHAR(15)      NULL,
    [Region]             NVARCHAR(15)      NULL,
    [PostalCode]         NVARCHAR(10)      NULL,
    [Country]            NVARCHAR(15)      NULL,
    [HomePhone]          NVARCHAR(24)      NULL,
    [Extension]          NVARCHAR(4)       NULL,
    [Notes]              NVARCHAR(MAX)     NULL,
    [ReportsTo]          INT               NULL,
    [TerritoryID]        NVARCHAR(20)      NULL,   -- de Territories
    [TerritoryDescription] NCHAR(50)       NULL,
    [RegionID]           INT               NULL,   -- de Region
    [RegionDescription]  NCHAR(50)         NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY ([EmployeeSK] ASC)
);