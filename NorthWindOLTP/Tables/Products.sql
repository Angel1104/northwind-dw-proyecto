CREATE TABLE [dbo].[Products](
	[ProductID]			[int] IDENTITY(1,1)		NOT NULL,
	[ProductName]		[nvarchar](40)			NOT NULL,
	[SupplierID]		[int]					NULL,
	[CategoryID]		[int]					NULL,
	[QuantityPerUnit]	[nvarchar](20)			NULL,
	[UnitPrice]			[money]					NULL,
	[UnitsInStock]		[smallint]				NULL,
	[UnitsOnOrder]		[smallint]				NULL,
	[ReorderLevel]		[smallint]				NULL,
	[Discontinued]		[bit]					NOT NULL,
	[rowversion]		[timestamp]				NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY 
(
	[ProductID] ASC
)
)
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitPrice]    DEFAULT ((0)) FOR [UnitPrice]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitsInStock] DEFAULT ((0)) FOR [UnitsInStock]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitsOnOrder] DEFAULT ((0)) FOR [UnitsOnOrder]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_ReorderLevel] DEFAULT ((0)) FOR [ReorderLevel]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_Discontinued] DEFAULT ((0)) FOR [Discontinued]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [FK_Products_Categories]
FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID])
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [FK_Products_Suppliers]
FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID])
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_Products_UnitPrice] CHECK ([UnitPrice] >= (0))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_ReorderLevel] CHECK ([ReorderLevel] >= (0))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_UnitsInStock] CHECK ([UnitsInStock] >= (0))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_UnitsOnOrder] CHECK ([UnitsOnOrder] >= (0))
GO

