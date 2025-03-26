CREATE DATABASE [Pharmacy]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Pharmacy', FILENAME = N'D:\SQL\Pharmacy.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Pharmacy_log', FILENAME = N'D:\SQL\Pharmacy_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO


CREATE TABLE [dbo].[Customers](
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[address] [nvarchar](255) DEFAULT NULL,
	[phone] [nvarchar](20) DEFAULT NULL,
 CONSTRAINT [PK__Customers_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Employees](
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[position] [nvarchar](100) DEFAULT NULL,
	[salary] [decimal](10,2) DEFAULT NULL,
 CONSTRAINT [PK__Employees_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Medicines](
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[type_id] [int] DEFAULT NULL,
	[supplier_id] [int] DEFAULT NULL,
	[price] [decimal](10,2) DEFAULT NULL,
	[quantity] [int] DEFAULT NULL,
 CONSTRAINT [PK__Medicines_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[MedicineTypes](
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__MedicineTypes_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Prescriptions](
	[id] [int] NOT NULL,
	[customer_id] [int] DEFAULT NULL,
	[medicine_id] [int] DEFAULT NULL,
	[employee_id] [int] DEFAULT NULL,
	[date] [date] DEFAULT NULL,
	[quantity] [int] DEFAULT NULL,
 CONSTRAINT [PK__Prescriptions_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Sales](
	[id] [int] NOT NULL,
	[customer_id] [int] DEFAULT NULL,
	[medicine_id] [int] DEFAULT NULL,
	[employee_id] [int] DEFAULT NULL,
	[date] [date] DEFAULT NULL,
	[quantity] [int] DEFAULT NULL,
	[price] [decimal](10,2) DEFAULT NULL,
 CONSTRAINT [PK__Sales_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Suppliers](
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[address] [nvarchar](255) DEFAULT NULL,
	[phone] [nvarchar](20) DEFAULT NULL,
 CONSTRAINT [PK__Suppliers_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[Medicines]  WITH CHECK ADD  CONSTRAINT [FK__Medicines_Suppliers] FOREIGN KEY([supplier_id])
REFERENCES [dbo].[Suppliers] ([id])
GO

ALTER TABLE [dbo].[Medicines] CHECK CONSTRAINT [FK__Medicines_Suppliers]
GO

ALTER TABLE [dbo].[Medicines]  WITH CHECK ADD  CONSTRAINT [FK__Medicines_MedicineTypes] FOREIGN KEY([type_id])
REFERENCES [dbo].[MedicineTypes] ([id])
GO

ALTER TABLE [dbo].[Medicines] CHECK CONSTRAINT [FK__Medicines_MedicineTypes]
GO

ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD  CONSTRAINT [FK__Prescriptions_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([id])
GO

ALTER TABLE [dbo].[Prescriptions] CHECK CONSTRAINT [FK__Prescriptions_Customers]
GO

ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD  CONSTRAINT [FK__Prescriptions_Medicines] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[Medicines] ([id])
GO

ALTER TABLE [dbo].[Prescriptions] CHECK CONSTRAINT [FK__Prescriptions_Medicines]
GO

ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD  CONSTRAINT [FK__Prescriptions_Employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[Employees] ([id])
GO

ALTER TABLE [dbo].[Prescriptions] CHECK CONSTRAINT [FK__Prescriptions_Employees]
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [FK__Sales_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([id])
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK__Sales_Customers]
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [FK__Sales_Medicines] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[Medicines] ([id])
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK__Sales_Medicines]
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [FK__Sales_Employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[Employees] ([id])
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK__Sales_Employees]
GO