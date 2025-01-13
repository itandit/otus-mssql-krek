/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/
;
USE WideWorldImporters
;
/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
;
USE WideWorldImporters
;
CREATE SCHEMA [test] AUTHORIZATION [dbo]	
;
DROP FUNCTION if exists test.getClientWithMaxPurchase
go
;
CREATE FUNCTION test.getClientWithMaxPurchase ()
RETURNS TABLE
as 
RETURN
(
with preselect as 
(
select InvoiceID, max(UnitPrice*Quantity) as [MaxSum]
from sales.InvoiceLines
where UnitPrice*Quantity = (select max(UnitPrice*Quantity) from sales.InvoiceLines)
group by UnitPrice*Quantity, InvoiceID
),
cte as
(
select * from sales.Invoices si
where si.InvoiceId in (select InvoiceId from preselect) 
)
select sc.CustomerId, CustomerName from cte
join sales.Customers sc on sc.CustomerId = cte.CustomerId
)
;
select * from test.getClientWithMaxPurchase()
;

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
;
USE WideWorldImporters;  
GO  
;
IF OBJECT_ID ( 'test.GetPurchaseSum', 'P' ) IS NOT NULL   
    DROP PROCEDURE test.GetPurchaseSum; 
GO
CREATE PROCEDURE test.GetPurchaseSum    
    @CustomerID int 
AS   

    SET NOCOUNT ON;  
	select UnitPrice*Quantity as [Sum], [Description] 
	from sales.Customers sc 
	join sales.Invoices si on sc.CustomerID = si.CustomerID
	join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	where sc.CustomerID = @CustomerID
GO 

exec test.GetPurchaseSum  @CustomerId=2

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
--- функция
CREATE FUNCTION test.SalesPeople ()
RETURNS TABLE  
AS  
RETURN 
(
select p.* from [Application].people p
where  IsSalesperson = 1 and not exists (select * from Sales.Invoices i
where i.ContactPersonID = p.PersonID 
and i.InvoiceDate<>'2013-06-04')
);
select * from test.SalesPeople ()

--процедура

IF OBJECT_ID ('test.SalesPeople_procedure', 'P' ) IS NOT NULL   
    DROP PROCEDURE test.SalesPeople_procedure;  
GO  
CREATE PROCEDURE test.SalesPeople_procedure 
AS  
    SET NOCOUNT ON;  
   select p.* from [Application].people p
where  IsSalesperson = 1 and not exists (select * from Sales.Invoices i
where i.ContactPersonID = p.PersonID 
and i.InvoiceDate<>'2013-06-04')  
GO  
 
exec test.SalesPeople_procedure

select * from test.SalesPeople()
exec test.SalesPeople_procedure

SET STATISTICS io ON
SET STATISTICS time ON

DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;
SET NOCOUNT ON

select * from test.SalesPeople()
exec test.SalesPeople_procedure

/*
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 102 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 109 мс.

*/

---функция работает быстрее

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

USE [tempdb] 
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[Employee]') AND type IN (N'U')) 
BEGIN 
   DROP TABLE [Employee] 
END 
GO 

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[Department]') AND type IN (N'U')) 
BEGIN 
   DROP TABLE [Department] 
END 

CREATE TABLE [Department]( 
   [DepartmentID] [int] NOT NULL PRIMARY KEY, 
   [Name] VARCHAR(250) NOT NULL, 
) ON [PRIMARY] 

INSERT [Department] ([DepartmentID], [Name])  
VALUES (1, N'profession0') 
INSERT [Department] ([DepartmentID], [Name])  
VALUES (2, N'profession1') 
INSERT [Department] ([DepartmentID], [Name])  
VALUES (3, N'profession2') 
INSERT [Department] ([DepartmentID], [Name])  
VALUES (4, N'profession3') 
INSERT [Department] ([DepartmentID], [Name])  
VALUES (5, N'profession4') 
GO 

CREATE TABLE [Employee]( 
   [EmployeeID] [int] NOT NULL PRIMARY KEY, 
   [FirstName] VARCHAR(250) NOT NULL, 
   [LastName] VARCHAR(250) NOT NULL, 
   [DepartmentID] [int] NOT NULL REFERENCES [Department](DepartmentID), 
) ON [PRIMARY] 
GO
 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) 
VALUES (1, N'name0', N'surname0', 1 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) 
VALUES (2, N'name1', N'surname1', 2 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) 
VALUES (3, N'name2', N'surname2', 3 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) 
VALUES (4, N'name3', N'surname', 3 ) 

drop function if exists test.TestFunction

CREATE FUNCTION test.TestFunction (@EmployeeId int)  
RETURNS TABLE
AS  
RETURN
(
select EmployeeID, FirstName, LastName,
E.DepartmentID, [Name] from Employee E
join Department D on 
E.DepartmentID = D.DepartmentID
where EmployeeID = @EmployeeId
);


select * 
from Department D
Cross apply test.TestFunction (D.DepartmentID) as a


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
