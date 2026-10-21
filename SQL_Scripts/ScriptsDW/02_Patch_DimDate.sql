USE [NorthWindDW]
GO

INSERT INTO [dbo].[DimDate]
           ([DateKey]
           ,[FullDate]
           ,[DayNumberOfWeek]
           ,[DayNameOfWeek]
           ,[DayNumberOfMonth]
           ,[DayNumberOfYear]
           ,[WeekNumberOfYear]
           ,[MonthName]
           ,[MonthNumberOfYear]
           ,[CalendarQuarter]
           ,[CalendarYear]
           ,[CalendarSemester])
     VALUES
           (0
           ,'1900-01-01'
           ,0
           ,'N/A'
           ,0
           ,0
           ,0
           ,'N/A'
           ,0
           ,0
           ,0
           ,0);
GO
