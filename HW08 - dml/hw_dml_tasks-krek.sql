/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

select *
from Sales.Customers


insert into Sales.Customers
(CustomerId,CustomerName, BillToCustomerId,CustomerCategoryId, 
PrimaryContactPersonId, AccountOpenedDate, AlternateContactPersonId,
DeliveryMethodId,DeliveryCityId, PostalCityId,StandardDiscountPercentage, 
IsStatementSent, IsOnCreditHold,PaymentDays, PhoneNumber,FaxNumber, WebsiteURL,DeliveryAddressLine1,
DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
values
(NEXT VALUE FOR Sequences.CustomerId, 'test customer 1', 1, 1, 1, '2024-01-01', 1, 1, 1, 1, 10,
1, 1, 12, N'(111)111-111',N'(111)111-111', 'https://test1.com', 'test1','test2','test3',34, 1),
(NEXT VALUE FOR Sequences.CustomerId, 'test customer 2', 1, 1, 1, '2024-02-02', 1, 1, 1, 1, 10,
1, 1, 12, N'(222)222-222',N'(222)222-222', 'https://test2.com', 'test1','test2','test3',34, 1),
(NEXT VALUE FOR Sequences.CustomerId, 'test customer 3', 1, 1, 1, '2024-03-03', 1, 1, 1, 1, 10,
1, 1, 12, N'(333)333-456',N'(333)333-456', 'https://test3.com', 'test1','test2','test3',34, 1),
(NEXT VALUE FOR Sequences.CustomerId, 'test customer 4', 1, 1, 1, '2024-04-04', 1, 1, 1, 1, 10,
1, 1, 12, N'(444)444-444',N'(444)444-444', 'https://test4.com', 'test1','test2','test3',34, 1),
(NEXT VALUE FOR Sequences.CustomerId, 'test customer 5', 1, 1, 1, '2024-05-05', 1, 1, 1, 1, 10,
1, 1, 12, N'(555)555-555',N'(555)555-555', 'https://test5.com', 'test1','test2','test3',34, 1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from Sales.Customers
where CustomerName = 'test customer 5'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update Sales.Customers 
set CustomerName = 'test customer 4 update'
where CustomerID = (select max(CustomerID) from Sales.Customers)

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

Merge sales.Customers as target
using(
select 'test customer 0 merge', 1, 1, 2, 1,'2024-10-10', 1, 1, 1, 1, 1, 1, 1, 100, N'(000)000-000', 
'(000)000-000', 'http://www.test0.com', 'test 0', 'test 0', 'test 0', 1, 1
)
as source (CustomerName, BillToCustomerId, CustomerCategoryId, BuyingGroupId, 
PrimaryContactPersonId, AccountOpenedDate, AlternateContactPersonId, DeliveryMethodId,
DeliveryCityId, PostalCityId, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, 
PaymentDays, PhoneNumber,FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, 
PostalAddressLine1, PostalPostalCode, LastEditedBy)
on (target.CustomerName = source.CustomerName)
when matched 
then update
set  CustomerName=source.CustomerName, BillToCustomerId=source.BillToCustomerId, 
CustomerCategoryId=source.CustomerCategoryId, BuyingGroupId=source.BuyingGroupId, 
PrimaryContactPersonId=source.PrimaryContactPersonId, AccountOpenedDate = source.AccountOpenedDate,
AlternateContactPersonId=source.AlternateContactPersonId,
DeliveryMethodId=source.DeliveryMethodId, DeliveryCityId=source.DeliveryCityId, 
PostalCityId=source.PostalCityId,StandardDiscountPercentage=source.StandardDiscountPercentage, 
IsStatementSent=source.IsStatementSent, IsOnCreditHold=source.IsOnCreditHold,
PaymentDays = source.PaymentDays, PhoneNumber=source.PhoneNumber,FaxNumber=source.FaxNumber, 
WebsiteURL = source.WebsiteURL, DeliveryAddressLine1 = source.DeliveryAddressLine1, 
DeliveryPostalCode = source.DeliveryPostalCode, PostalAddressLine1 = source.PostalAddressLine1,
PostalPostalCode = source.PostalPostalCode, LastEditedBy = source.LastEditedBy
when not matched
then insert (CustomerName, BillToCustomerId,CustomerCategoryId, 
PrimaryContactPersonId, AccountOpenedDate, AlternateContactPersonId,
DeliveryMethodId,DeliveryCityId, PostalCityId,StandardDiscountPercentage, 
IsStatementSent, IsOnCreditHold,PaymentDays, PhoneNumber,FaxNumber, WebsiteURL,DeliveryAddressLine1,
DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
values(source.CustomerName, source.BillToCustomerId,source.CustomerCategoryId, 
source.PrimaryContactPersonId, source.AccountOpenedDate, source.AlternateContactPersonId,
source.DeliveryMethodId, source.DeliveryCityId, 
source.PostalCityId,source.StandardDiscountPercentage, 
source.IsStatementSent, source.IsOnCreditHold, source.PaymentDays,
source.PhoneNumber,source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, 
source.DeliveryPostalCode, source.PostalAddressLine1, source.PostalPostalCode, source.LastEditedBy)
OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Invoices" out  "D:\Invoices1.csv" -T -w -t;'

drop table if exists Sales.Invoices_bulked
select * into Sales.Invoices_bulked
from sales.Invoices
where 1=2

BULK INSERT Sales.Invoices_bulked
FROM "D:\Invoices1.csv"
WITH 
(
BATCHSIZE = 1000, 
DATAFILETYPE = 'widechar',
FIELDTERMINATOR = ';',
ROWTERMINATOR ='\n',
KEEPNULLS,
TABLOCK        
);

