use Pharmacy

--Customers таблица

--Индекс на name
--Ускорит поиск клиентов по имени
CREATE NONCLUSTERED INDEX IX_Customers_Name ON Customers (name);

--Employees таблица

--Индекс на position
--Ускорит поиск сотрудников по должности
CREATE NONCLUSTERED INDEX IX_Employees_Position ON Employees (position);

--Medicines таблица

--Индекс на type_id
--Ускорит поиск лекарств по типу
CREATE NONCLUSTERED INDEX IX_Medicines_TypeId ON Medicines (type_id);

--Индекс на supplier_id
--Ускорит поиск лекарств по поставщику
CREATE NONCLUSTERED INDEX IX_Medicines_SupplierId ON Medicines (supplier_id);

--Составной индекс на name, type_id
--Ускорит запросы, фильтрующие по имени и типу лекарства
CREATE NONCLUSTERED INDEX IX_Medicines_Name_TypeId ON Medicines (name, type_id);

--MedicineTypes таблица

--Индекс на name
--Ускорит поиск типов лекарств по имени.
CREATE NONCLUSTERED INDEX IX_MedicineTypes_Name ON MedicineTypes (name);

--Prescriptions таблица

--Индекс на customer_id
--Ускорит поиск рецептов для конкретного клиента.
CREATE NONCLUSTERED INDEX IX_Prescriptions_CustomerId ON Prescriptions (customer_id);

--Индекс на medicine_id
--Ускорит поиск рецептов на конкретное лекарство.
CREATE NONCLUSTERED INDEX IX_Prescriptions_MedicineId ON Prescriptions (medicine_id);

--Индекс на employee_id
--Ускорит поиск рецептов, выписанных конкретным сотрудником.
CREATE NONCLUSTERED INDEX IX_Prescriptions_EmployeeId ON Prescriptions (employee_id);

--Составной индекс на customer_id, date
--Ускорит запросы, которые ищут рецепты конкретного клиента за определенный период времени.
CREATE NONCLUSTERED INDEX IX_Prescriptions_CustomerId_Date ON Prescriptions (customer_id, date);

--Sales таблица

--Индекс на customer_id
--Ускорит поиск продаж конкретного клиента.
CREATE NONCLUSTERED INDEX IX_Sales_CustomerId ON Sales (customer_id);

--Индекс на medicine_id
--Ускорит поиск продаж конкретного лекарства.
CREATE NONCLUSTERED INDEX IX_Sales_MedicineId ON Sales (medicine_id);

--Индекс на employee_id
--Ускорит поиск продаж, совершенных конкретным сотрудником.
CREATE NONCLUSTERED INDEX IX_Sales_EmployeeId ON Sales (employee_id);

--Составной индекс на customer_id, date
--Ускорит запросы, которые ищут продажи конкретного клиента за определенный период времени.
CREATE NONCLUSTERED INDEX IX_Sales_CustomerId_Date ON Sales (customer_id, date);

--Suppliers таблица
--Ускорит поиск поставщиков по имени.
CREATE NONCLUSTERED INDEX IX_Suppliers_Name ON Suppliers (name);

