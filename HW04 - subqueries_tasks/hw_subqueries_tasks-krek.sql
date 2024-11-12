/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
;
select p.PersonID, p.FullName
from Application.People p
where not exists (
select *
from Sales.Invoices i
where i.ContactPersonID = p.PersonID 
and i.InvoiceDate != '20150704'
) and p.IsSalesperson = 1
;
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
;
select si.StockItemID, si.StockItemName, si.UnitPrice
from Warehouse.StockItems si
where si.UnitPrice = any (
select min(s.UnitPrice)
from Warehouse.StockItems s
)
;
select si.StockItemID, si.StockItemName, si.UnitPrice
from Warehouse.StockItems si
where si.UnitPrice in (
select min(s.UnitPrice)
from Warehouse.StockItems s
)
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
;
with tt as (
select c.CustomerName, ct.TransactionAmount
from Sales.CustomerTransactions ct
join Sales.Customers c on ct.CustomerID = c.CustomerID
)
select top 5 CustomerName, TransactionAmount
from tt 
order by TransactionAmount desc
;
select c.CustomerName, ct.TransactionAmount
from Sales.Customers c
join Sales.CustomerTransactions ct  on c.CustomerID = ct.CustomerID
where ct.TransactionAmount in (
select top 5 TransactionAmount 
from Sales.CustomerTransactions
order by TransactionAmount desc
)
order by TransactionAmount desc

;
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

;
select c.CityID, c.CityName, cs.CustomerID, si.StockItemName, 
si.UnitPrice, i.PackedByPersonID, p.FullName
from Application.Cities c
join Sales.Customers cs on c.CityID = cs.DeliveryCityID
join Sales.Orders o on cs.CustomerId = o.CustomerID
join Sales.OrderLines ol on ol.OrderID = o.OrderID
join Warehouse.StockItems si on si.StockItemID = ol.StockItemID
join Sales.Invoices i on i.OrderID = o.OrderID
join Application.People p on p.PersonID = i.PackedByPersonID
where ol.UnitPrice in (
select top 3 UnitPrice 
from Warehouse.StockItems
order by UnitPrice desc)
order by si.UnitPrice desc
;

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

--Скрипт собирает: номер заказа, дата заказа, имя сейлза, сумма заказа более 27000 и сумма собранного заказ
--Добавил CTE, присвоил алиасы
;

with 
TotalSum AS (
SELECT 
 il.InvoiceID
,SUM(il.UnitPrice * il.Quantity) TotalInvoiceSum
FROM Sales.InvoiceLines il
GROUP BY il.InvoiceID
HAVING SUM(il.UnitPrice * il.Quantity) > 27000
),
TotalPick AS (
SELECT 
 o.OrderID
,SUM(ol.PickedQuantity*ol.UnitPrice) TotalPickSum
FROM Sales.Orders o 
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID and ol.PickingCompletedWhen IS NOT NULL
GROUP BY o.OrderID
)
SELECT 
 i.InvoiceID
,i.InvoiceDate
,p.FullName SalesPersonName
,ts.TotalInvoiceSum TotalSummByInvoice
,tp.TotalPickSum TotalSummForPickedItems
FROM Sales.Invoices i
JOIN Application.People p ON p.PersonID = i.SalespersonPersonID
JOIN TotalSum ts ON i.InvoiceID = ts.InvoiceID
JOIN TotalPick tp ON i.OrderID = tp.OrderID
ORDER BY ts.TotalInvoiceSum DESC

;