CREATE TABLE [dbo].[DimShipper]
(
    [ShipperSK]    INT IDENTITY(1,1) NOT NULL,   -- SK
    [ShipperID]     INT               NOT NULL,   -- clave natural
    [CompanyName]   NVARCHAR(40)      NOT NULL,
    [Phone]         NVARCHAR(24)      NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY ([ShipperSK] ASC)
);