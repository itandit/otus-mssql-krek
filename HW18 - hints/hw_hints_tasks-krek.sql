use WideWorldImporters

DBCC FREEPROCCACHE

SET STATISTICS IO ON 
SET STATISTICS time ON 

--------базовый запрос---------

Select ord.CustomerID, det.StockItemID, 
SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (Select SupplierId
FROM Warehouse.StockItems AS It
Where It.StockItemID = det.StockItemID) = 12
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
;

----- оптимальный запрос без хинтов-----------
;
SELECT 
ord.CustomerID 
,det.StockItemID 
,SUM(det.UnitPrice) TotalUnitPrice 
,SUM(det.Quantity) TotalQuantity 
,COUNT(DISTINCT ord.OrderID) OrderCount
FROM Sales.Orders ord
JOIN Sales.OrderLines det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID and Inv.BillToCustomerID != ord.CustomerID
JOIN Warehouse.StockItems It ON It.StockItemID = det.StockItemID AND It.SupplierID = 12  
GROUP BY  ord.CustomerID, det.StockItemID
ORDER BY  ord.CustomerID, det.StockItemID
;

---------запрос с хинтами----

------индексы не создавал, поэтому без джоиновых хинтов----

SELECT 
ord.CustomerID
,det.StockItemID
,SUM(det.UnitPrice) TotalUnitPrice
,SUM(det.Quantity) TotalQuantity
COUNT(DISTINCT ord.OrderID) OrderCount
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Warehouse.StockItems AS It ON It.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID AND It.SupplierID = 12
GROUP BY ord.CustomerID, det.StockItemID 
ORDER BY ord.CustomerID, det.StockItemID
------добавил только оптимизаторы ----------
OPTION (HASH GROUP, MERGE JOIN, FORCE ORDER);

