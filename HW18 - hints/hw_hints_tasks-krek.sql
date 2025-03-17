use WideWorldImporters

DBCC FREEPROCCACHE

SET STATISTICS IO ON 
SET STATISTICS time ON 

--------базовый запрос---------

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
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
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID



---------запрос с хинтами----

WITH SupplierStockItems AS (
    SELECT StockItemID
    FROM Warehouse.StockItems
    WHERE SupplierId = 12
),
CustomerTotalSpent AS (
    SELECT ordTotal.CustomerID, SUM(Total.UnitPrice * Total.Quantity) AS TotalSpent
    FROM Sales.OrderLines AS Total
    JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    GROUP BY ordTotal.CustomerID
    HAVING SUM(Total.UnitPrice * Total.Quantity) > 250000
)
SELECT ord.CustomerID, 
       det.StockItemID, 
       SUM(det.UnitPrice) AS TotalUnitPrice, 
       SUM(det.Quantity) AS TotalQuantity, 
       COUNT(ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
JOIN SupplierStockItems AS ssi ON ssi.StockItemID = det.StockItemID
JOIN CustomerTotalSpent AS cts ON cts.CustomerID = Inv.CustomerID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
OPTION (RECOMPILE, HASH GROUP, MERGE JOIN, FORCE ORDER, MAXDOP 1);

