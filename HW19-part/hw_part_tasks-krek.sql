use WideWorldImporters

ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO


ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\SQL\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'fnYearPartition')
BEGIN
    CREATE PARTITION FUNCTION [fnYearPartition](DATE) 
    AS RANGE RIGHT FOR VALUES 
    ('20120101','20130101','20140101','20150101','20160101', 
     '20170101','20180101', '20190101', '20200101', '20210101');
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'schmYearPartition')
BEGIN
    CREATE PARTITION SCHEME [schmYearPartition] 
    AS PARTITION [fnYearPartition] ALL TO ([YearData])
END
GO



IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InvoiceLinesYears' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[InvoiceLinesYears](
        [InvoiceLineID] [int] NOT NULL,
        [InvoiceID] [int] NOT NULL,
        [InvoiceDate] [date] NOT NULL,
        [StockItemID] [int] NOT NULL,
        [Description] [nvarchar](100) NOT NULL,
        [PackageTypeID] [int] NOT NULL,
        [Quantity] [int] NOT NULL,
        [UnitPrice] [decimal](18, 2) NULL,
        [TaxRate] [decimal](18, 3) NOT NULL,
        [TaxAmount] [decimal](18, 2) NOT NULL,
        [LineProfit] [decimal](18, 2) NOT NULL,
        [ExtendedPrice] [decimal](18, 2) NOT NULL,
        [LastEditedBy] [int] NOT NULL,
        [LastEditedWhen] [datetime2](7) NOT NULL
    ) ON [schmYearPartition]([InvoiceDate])
    
    ALTER TABLE [Sales].[InvoiceLinesYears] 
    ADD CONSTRAINT PK_Sales_InvoiceLinesYears 
    PRIMARY KEY CLUSTERED (InvoiceDate, InvoiceID, InvoiceLineID) 
    ON [schmYearPartition]([InvoiceDate]);
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InvoicesYears' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[InvoicesYears](
        [InvoiceID] [int] NOT NULL,
        [CustomerID] [int] NOT NULL,
        [BillToCustomerID] [int] NOT NULL,
        [OrderID] [int] NULL,
        [DeliveryMethodID] [int] NOT NULL,
        [ContactPersonID] [int] NOT NULL,
        [AccountsPersonID] [int] NOT NULL,
        [SalespersonPersonID] [int] NOT NULL,
        [PackedByPersonID] [int] NOT NULL,
        [InvoiceDate] [date] NOT NULL,
        [CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
        [IsCreditNote] [bit] NOT NULL,
        [CreditNoteReason] [nvarchar](max) NULL,
        [Comments] [nvarchar](max) NULL,
        [DeliveryInstructions] [nvarchar](max) NULL,
        [InternalComments] [nvarchar](max) NULL
    ) ON [schmYearPartition]([InvoiceDate])
    
    ALTER TABLE [Sales].[InvoicesYears] 
    ADD CONSTRAINT PK_Sales_InvoicesYears 
    PRIMARY KEY CLUSTERED (InvoiceDate, InvoiceID) 
    ON [schmYearPartition]([InvoiceDate]);
END
GO


INSERT INTO [Sales].[InvoicesYears]
SELECT 
    i.InvoiceID,
    i.CustomerID,
    i.BillToCustomerID,
    i.OrderID,
    i.DeliveryMethodID,
    i.ContactPersonID,
    i.AccountsPersonID,
    i.SalespersonPersonID,
    i.PackedByPersonID,
    i.InvoiceDate,
    i.CustomerPurchaseOrderNumber,
    i.IsCreditNote,
    i.CreditNoteReason,
    i.Comments,
    i.DeliveryInstructions,
    i.InternalComments
FROM [Sales].[Invoices] i;
GO



INSERT INTO [Sales].[InvoiceLinesYears]
SELECT 
    il.InvoiceLineID,
    il.InvoiceID,
    i.InvoiceDate, 
    il.StockItemID,
    il.Description,
    il.PackageTypeID,
    il.Quantity,
    il.UnitPrice,
    il.TaxRate,
    il.TaxAmount,
    il.LineProfit,
    il.ExtendedPrice,
    il.LastEditedBy,
    il.LastEditedWhen
FROM [Sales].[InvoiceLines] il
JOIN [Sales].[Invoices] i ON il.InvoiceID = i.InvoiceID;
GO


SELECT 
    $PARTITION.fnYearPartition(InvoiceDate) AS Partition,
    COUNT(*) AS [count],
    MIN(InvoiceDate) as [min],
    MAX(InvoiceDate) as [max]
FROM [Sales].[InvoicesYears]
GROUP BY $PARTITION.fnYearPartition(InvoiceDate)
ORDER BY Partition;
GO


SELECT DISTINCT t.name
FROM sys.partitions p
INNER JOIN sys.tables t ON p.object_id = t.object_id
WHERE p.partition_number <> 1;
GO