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

---------запрос написанный иначе----


SELECT 
    ord.CustomerID, 
    det.StockItemID, 
    SUM(det.UnitPrice) AS TotalUnitPrice, 
    SUM(det.Quantity) AS TotalQuantity, 
    COUNT(ord.OrderID) AS OrderCount
FROM 
    Sales.Orders AS ord
JOIN 
    Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN 
    Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN 
    Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN 
    Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
JOIN 
    Warehouse.StockItems AS It ON It.StockItemID = det.StockItemID
WHERE 
    Inv.BillToCustomerID != ord.CustomerID
    AND It.SupplierId = 12
    AND DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY 
    ord.CustomerID, 
    det.StockItemID
HAVING 
    SUM(det.UnitPrice * det.Quantity) > 250000
ORDER BY 
    ord.CustomerID, 
    det.StockItemID;

---------запрос написанный иначе----

SELECT ord.CustomerID, det.StockItemID, 
       SUM(det.UnitPrice) AS TotalUnitPrice, 
       SUM(det.Quantity) AS TotalQuantity, 
       COUNT(DISTINCT ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
JOIN (
SELECT StockItemID
FROM Warehouse.StockItems
WHERE SupplierID = 12
) AS si ON si.StockItemID = det.StockItemID
JOIN (
SELECT ordTotal.CustomerID
FROM Sales.OrderLines AS Total
JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
GROUP BY ordTotal.CustomerID
HAVING SUM(Total.UnitPrice * Total.Quantity) > 250000
) AS cs ON cs.CustomerID = Inv.CustomerID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;


