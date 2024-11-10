/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
;
select StockItemID , StockItemName 
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'
;

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID , s.SupplierName 
from Purchasing.Suppliers s
left join Purchasing.PurchaseOrders p on s.SupplierID = p.SupplierID
where p.SupplierID is null
/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
;
select 
 o.OrderID 
,format(o.OrderDate, 'dd.MM.yyyy') OrderDate 
,datename(month, o.OrderDate) OrderMonth
,datepart(quarter, o.OrderDate) OrderQuarter
,case 
 when month(o.OrderDate) <= 4 then 1
 when month(o.OrderDate) <= 8 then 2
 else 3 end PartYear
,c.CustomerName
from Sales.Customers c
join Sales.Orders o on c.CustomerID = o.CustomerID
join Sales.OrderLines ol on ol.OrderID = o.OrderID 
<<<<<<< HEAD
where ol.UnitPrice > 100 or (ol.Quantity > 20 and o.PickingCompletedWhen is not null)
=======
where ol.UnitPrice > 100 or ol.Quantity > 20 and o.PickingCompletedWhen is not null
>>>>>>> a7baa64b49659fa9c9522622cd3473b2c14d6107
group by o.OrderID, o.OrderDate, c.CustomerName
order by OrderQuarter, PartYear, o.OrderDate
offset 1000 rows
fetch next 100 rows only 
;


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
;
select po.PurchaseOrderID,dm.DeliveryMethodName, po.ExpectedDeliveryDate,s.SupplierName,p.FullName
from Purchasing.PurchaseOrders po 
join Purchasing.Suppliers s on s.SupplierID = po.SupplierID
<<<<<<< HEAD
join Application.DeliveryMethods dm on dm.DeliveryMethodID = po.DeliveryMethodID 
join Application.People p on p.PersonID = po.ContactPersonID
where po.IsOrderFinalized = 1 and po.ExpectedDeliveryDate between '20130101' and '20230131'
and dm.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')
=======
join Application.DeliveryMethods dm on dm.DeliveryMethodID = po.DeliveryMethodID and dm.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')
join Application.People p on p.PersonID = po.ContactPersonID
where po.IsOrderFinalized = 1 and po.ExpectedDeliveryDate between '20130101' and '20230131'
>>>>>>> a7baa64b49659fa9c9522622cd3473b2c14d6107
;

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
;
<<<<<<< HEAD
  select top (10) with ties o.OrderDate, p.FullName, c.CustomerName
=======
  select top (10) o.OrderDate, p.FullName, c.CustomerName
>>>>>>> a7baa64b49659fa9c9522622cd3473b2c14d6107
  from Sales.Orders o
  join Application.People p on p.PersonID = o.SalespersonPersonID
  join Sales.Customers c on c.CustomerID = o.CustomerID
  order by o.OrderID desc

;


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/
;
select c.CustomerID, c.CustomerName, c.PhoneNumber
from Sales.Customers c
join Sales.Orders o on c.CustomerID = o.CustomerID
join Sales.OrderLines ol on o.OrderID = ol.OrderID
<<<<<<< HEAD
join Warehouse.StockItems si on si.StockItemID = ol.StockItemID
where si.StockItemName = 'Chocolate frogs 250g'
=======
join Warehouse.StockItems si on si.StockItemID = ol.StockItemID and si.StockItemName = 'Chocolate frogs 250g'
>>>>>>> a7baa64b49659fa9c9522622cd3473b2c14d6107
group by c.CustomerID, c.CustomerName, c.PhoneNumber
;