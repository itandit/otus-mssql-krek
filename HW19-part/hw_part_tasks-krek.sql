use [Pharmacy]

ALTER DATABASE [Pharmacy] ADD FILEGROUP [SalesData]
GO

ALTER DATABASE [VetShop] ADD FILE 
(NAME = N'SaleDate', FILENAME = N'D:\SQL\SalesData.ndf' , 
SIZE=4MB, MAXSIZE=10MB,FILEGROWTH=1MB ) TO FILEGROUP [SalesData]
GO

drop function if exists [fnSaleDatePartition]

CREATE PARTITION FUNCTION [fnSalesDatePartition](DATE) AS RANGE right FOR VALUES
('20220101','20230101','20240101');																																																									
GO



CREATE PARTITION SCHEME [schmSalesDatePartition] AS PARTITION [fnSalesDatePartition] 
ALL TO ([SalesData])
GO

SELECT * INTO dbo.OrdersPartitioned
FROM dbo.Sales

select * from dbo.OrdersPartitioned


ALTER TABLE [Sales].[Orders] ADD CONSTRAINT PK_Sales_OrdersPartitioned 
PRIMARY KEY CLUSTERED  (OrderId, SaleDate)
ON [schmSalesDatePartition]([SaleDate]);



select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1


SELECT  $PARTITION.fnSaleDatePartition(SaleDate) AS Partition
		, COUNT(*) AS [count]
		, MIN(SaleDate) as [min]
		,MAX(SaleDate) as [max]
FROM dbo.Sales
GROUP BY $PARTITION.fnSaleDatePartition(SaleDate) 
ORDER BY Partition ;  