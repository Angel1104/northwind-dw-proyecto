CREATE TABLE [dbo].[Orders](
	[OrderID]			[int] IDENTITY(1,1)		NOT NULL,
	[CustomerID]		[nchar](5)				NULL,
	[EmployeeID]		[int]					NULL,
	[OrderDate]			[datetime]				NULL,
	[RequiredDate]		[datetime]				NULL,
	[ShippedDate]		[datetime]				NULL,
	[ShipVia]			[int]					NULL,
	[Freight]			[money]					NULL,
	[ShipName]			[nvarchar](40)			NULL,
	[ShipAddress]		[nvarchar](60)			NULL,
	[ShipCity]			[nvarchar](15)			NULL,
	[ShipRegion]		[nvarchar](15)			NULL,
	[ShipPostalCode]	[nvarchar](10)			NULL,
	[ShipCountry]		[nvarchar](15)			NULL,
	[rowversion]		[timestamp]				NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY 
(
	[OrderID] ASC
)
)
GO

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_Freight] DEFAULT ((0)) FOR [Freight]
GO

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [FK_Orders_Customers]
FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [FK_Orders_Employees]
FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID])
GO

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [FK_Orders_Shippers]
FOREIGN KEY ([ShipVia]) REFERENCES [dbo].[Shippers] ([ShipperID])
GO
