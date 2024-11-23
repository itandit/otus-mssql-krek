/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
;
with tmp as (
select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.UnitPrice * il.Quantity)  InvoiceSum
from Sales.Invoices i 
join Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
join Sales.Customers c on i.CustomerID = c.CustomerID 
where i.InvoiceDate >= '20150101'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
)
select InvoiceID, CustomerName, InvoiceDate, InvoiceSum
,(select sum(tmp.InvoiceSum) from tmp where tmp.InvoiceDate <= eomonth(cum.InvoiceDate)) MonthCum
from tmp cum

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
set statistics time, io on

with tmp as (
select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.UnitPrice * il.Quantity)  InvoiceSum
from Sales.Invoices i 
join Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
join Sales.Customers c on i.CustomerID = c.CustomerID 
where i.InvoiceDate >= '20150101'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
)
select InvoiceID, CustomerName, InvoiceDate, InvoiceSum
,sum(InvoiceSum) over (order by eomonth(InvoiceDate)) MonthCum
from tmp

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;
select dt "Дата", nm "Наименование товара", qty "Количество"
from (
select dt, nm, qty, row_number() over (partition by dt order by qty desc) rn
from (
select eomonth(i.InvoiceDate) dt, s.StockItemName nm, sum(il.Quantity ) qty
from Sales.Invoices i 
join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID 
join Warehouse.StockItems s ON il.StockItemID  = s.StockItemID 
where i.InvoiceDate between '20160101' and '20161231'
group by eomonth(i.InvoiceDate), s.StockItemName
) tt
) qq
where rn <= 2
order by dt
;
/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
;
select StockItemID, StockItemName, Brand, RecommendedRetailPrice
, row_number() over(partition by left(StockItemName,1) order by StockItemName) rn_name_1
, count(*) over() cnt_total
, count(*) over (partition by left(StockItemName,1) order by StockItemName) cnt_total_name_1
, lead(StockItemId) over (order by StockItemName) ld_id 
, lag(StockItemId) over (order by StockItemName) lg_id
, lag(StockItemName, 2, 'No items') over (order by StockItemName) lg_name_2
, ntile(30) over (order by TypicalWeightPerUnit) nt_30
from Warehouse.StockItems
order by StockItemName
;
/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
;

select PersonId, FullName, CustomerId, CustomerName, TransactionDate, TransactionAmount
from (
select p.PersonId, p.FullName, c.CustomerId, CustomerName,ct.TransactionDate, ct.TransactionAmount
, row_number() over (partition by ii.SalespersonPersonID order by ct.TransactionDate) rn
from Sales.Invoices i
join Sales.CustomerTransactions ct on i.InvoiceId = ct.InvoiceId
join Sales.Customers c on c.CustomerId = ct.CustomerId
join Sales.Invoices ii on ii.InvoiceId = i.InvoiceId
join Application.People p on p.PersonId = ii.SalespersonPersonID
) tt
where rn = 1

;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
;
select c.CustomerId, c.CustomerName, StockItemID, UnitPrice, InvoiceDate 
from (
select distinct CustomerId, StockItemID, InvoiceDate, UnitPrice, rank() over(partition by CustomerId order by UnitPrice desc) rn
from sales.Invoices si
join sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
) a
join sales.Customers c on c.CustomerID = a.CustomerID
where rn <=2

