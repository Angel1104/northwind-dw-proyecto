CREATE TABLE [staging].[customer]
(
    [CustomerSK]       INT               NOT NULL,
    [CustomerID]       NCHAR(5)          NOT NULL,
    [CompanyName]      NVARCHAR(40)      NOT NULL,
    [ContactName]      NVARCHAR(30)      NULL,
    [ContactTitle]     NVARCHAR(30)      NULL,
    [Address]          NVARCHAR(60)      NULL,
    [City]             NVARCHAR(15)      NULL,
    [Region]           NVARCHAR(15)      NULL,
    [PostalCode]       NVARCHAR(10)      NULL,
    [Country]          NVARCHAR(15)      NULL,
    [Phone]            NVARCHAR(24)      NULL,
    [Fax]              NVARCHAR(24)      NULL,
    [CustomerTypeID]   NVARCHAR(10)      NULL,
    [CustomerDesc]     NVARCHAR(MAX)     NULL
);
GO
