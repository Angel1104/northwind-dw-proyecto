CREATE TABLE [dbo].[OrderDetails](
	[OrderID]		[int]			NOT NULL,
	[ProductID]		[int]			NOT NULL,
	[UnitPrice]		[money]			NOT NULL,
	[Quantity]		[smallint]		NOT NULL,
	[Discount]		[real]			NOT NULL,
	[rowversion]	[timestamp]		NULL,
 CONSTRAINT [PK_Order_Details] PRIMARY KEY 
(
	[OrderID] ASC,
	[ProductID] ASC
)
)
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_UnitPrice] DEFAULT ((0)) FOR [UnitPrice]
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_Quantity]  DEFAULT ((1)) FOR [Quantity]
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_Discount]  DEFAULT ((0)) FOR [Discount]
GO


ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [FK_Order_Details_Orders]
FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID])
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [FK_Order_Details_Products]
FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_Discount] CHECK ([Discount] >= (0) AND [Discount] <= (1))
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_Quantity] CHECK ([Quantity] > (0))
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_UnitPrice] CHECK ([UnitPrice] >= (0))
GO
