/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/


select *
from (
select
substring(c.CustomerName, charindex('(', c.CustomerName) + 1, len(c.CustomerName) - charindex('(', c.CustomerName) - 1) CustomerName,
format(dateadd(MM, datediff(MM, 0, i.InvoiceDate), 0), 'dd.MM.yyyy') InvoiceMonth
from Sales.Customers c
join Sales.Invoices i ON i.CustomerID = c.CustomerID 
where c.CustomerID BETWEEN 2 AND 6
) CustomerInvoices
pivot (
count(CustomerName)
for CustomerName IN ([Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Sylvanite, MT], [Jessie, ND])
) AS pvt
order by eomonth(InvoiceMonth);

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
select CustomerName, AddressLine
from (
select 
CustomerName
, DeliveryAddressLine1
, DeliveryAddressLine2
, PostalAddressLine1
, PostalAddressLine2 from 
Sales.Customers where CustomerName like 'Tailspin Toys%'
) tt
unpivot (AddressLine for [Address] in (DeliveryAddressLine1
, DeliveryAddressLine2
, PostalAddressLine1
, PostalAddressLine2)) as unvpt

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryId, CountryName, Code 
from
(select CountryId, CountryName, 
IsoAlpha3Code, cast(IsoNumericCode as nvarchar(3)) as IsoNumericCode
from [Application].Countries ) tt
unpivot (Code for CodeType in (IsoAlpha3Code,IsoNumericCode )) 
unpvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select c.CustomerID, CustomerName, StockItemID, InvoiceDate, tt.UnitPrice
from sales.Customers c
cross apply (select top 2 CustomerID, StockItemID, InvoiceDate, UnitPrice
from sales.Invoices i 
join sales.OrderLines o on o.OrderID = i.OrderID
where c.CustomerID = i.CustomerID
order by UnitPrice desc
)
as tt
order by c.CustomerID, tt.UnitPrice desc
