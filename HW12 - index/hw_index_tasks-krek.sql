use Pharmacy

--Customers �������

--������ �� name
--������� ����� �������� �� �����
CREATE NONCLUSTERED INDEX IX_Customers_Name ON Customers (name);

--Employees �������

--������ �� position
--������� ����� ����������� �� ���������
CREATE NONCLUSTERED INDEX IX_Employees_Position ON Employees (position);

--Medicines �������

--������ �� type_id
--������� ����� �������� �� ����
CREATE NONCLUSTERED INDEX IX_Medicines_TypeId ON Medicines (type_id);

--������ �� supplier_id
--������� ����� �������� �� ����������
CREATE NONCLUSTERED INDEX IX_Medicines_SupplierId ON Medicines (supplier_id);

--��������� ������ �� name, type_id
--������� �������, ����������� �� ����� � ���� ���������
CREATE NONCLUSTERED INDEX IX_Medicines_Name_TypeId ON Medicines (name, type_id);

--MedicineTypes �������

--������ �� name
--������� ����� ����� �������� �� �����.
CREATE NONCLUSTERED INDEX IX_MedicineTypes_Name ON MedicineTypes (name);

--Prescriptions �������

--������ �� customer_id
--������� ����� �������� ��� ����������� �������.
CREATE NONCLUSTERED INDEX IX_Prescriptions_CustomerId ON Prescriptions (customer_id);

--������ �� medicine_id
--������� ����� �������� �� ���������� ���������.
CREATE NONCLUSTERED INDEX IX_Prescriptions_MedicineId ON Prescriptions (medicine_id);

--������ �� employee_id
--������� ����� ��������, ���������� ���������� �����������.
CREATE NONCLUSTERED INDEX IX_Prescriptions_EmployeeId ON Prescriptions (employee_id);

--��������� ������ �� customer_id, date
--������� �������, ������� ���� ������� ����������� ������� �� ������������ ������ �������.
CREATE NONCLUSTERED INDEX IX_Prescriptions_CustomerId_Date ON Prescriptions (customer_id, date);

--Sales �������

--������ �� customer_id
--������� ����� ������ ����������� �������.
CREATE NONCLUSTERED INDEX IX_Sales_CustomerId ON Sales (customer_id);

--������ �� medicine_id
--������� ����� ������ ����������� ���������.
CREATE NONCLUSTERED INDEX IX_Sales_MedicineId ON Sales (medicine_id);

--������ �� employee_id
--������� ����� ������, ����������� ���������� �����������.
CREATE NONCLUSTERED INDEX IX_Sales_EmployeeId ON Sales (employee_id);

--��������� ������ �� customer_id, date
--������� �������, ������� ���� ������� ����������� ������� �� ������������ ������ �������.
CREATE NONCLUSTERED INDEX IX_Sales_CustomerId_Date ON Sales (customer_id, date);

--Suppliers �������
--������� ����� ����������� �� �����.
CREATE NONCLUSTERED INDEX IX_Suppliers_Name ON Suppliers (name);

