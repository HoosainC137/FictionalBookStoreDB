create database [Bookworm Haven];

USE [Bookworm Haven];

-- Create table Authors first because table Books can't be created first as the primary key in Authors references the foreign key in table Books
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100),
    Nationality VARCHAR(100),
    BirthYear INT
);

-- Create table Books
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(200),
    AuthorID INT,
    Genre VARCHAR(100),
    Price DECIMAL(10, 2),
    PublicationYear INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Create table Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200)
);

-- Create table Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create table OrderItems
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    BookID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Insert data into Authors table
INSERT INTO Authors (AuthorID, AuthorName, Nationality, BirthYear)
VALUES
    (101, 'John Doe', 'British', 1965),
    (102, 'Jane Smith', 'American', 1980),
    (103, 'David Lee', 'Canadian', 1972);

-- Insert data into Books table
INSERT INTO Books (BookID, Title, AuthorID, Genre, Price, PublicationYear)
VALUES
    (1, 'Harry Potter Series', 101, 'Fiction', 25.99, 2000),
    (2, 'To Kill a Mockingbird', 102, 'Novel', 19.99, 1960),
    (3, 'The Great Gatsby', 103, 'Classic', 15.99, 1922),
    (4, 'Pride and Prejudice', 101, 'Romance', 12.99, 1813);

-- Insert data into Customers table
INSERT INTO Customers (CustomerID, CustomerName, Email, Phone, Address)
VALUES
    (201, 'John Doe', 'john.doe@example.com', '123-456-7890', '123 Main Street'),
    (202, 'Jane Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak Avenue'),
    (203, 'David Lee', 'david.lee@example.com', '555-123-4567', '786 Maple Street');

-- Insert data into Orders table
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
    (301, 201, '2023-07-01', 90),
    (302, 202, '2023-07-02', 35),
    (303, 203, '2023-07-03', 70);

-- Insert data into OrderItems table
INSERT INTO OrderItems (OrderItemID, OrderID, BookID, Quantity)
VALUES
    (401, 301, 1, 2),
    (402, 301, 2, 1),
    (403, 302, 3, 1),
    (404, 303, 4, 2);

	select * from Authors
	select * from Books
	select * from Customers
	select * from Orders
	select * from OrderItems

-- Create users without login
CREATE USER JohnDoeUser WITHOUT LOGIN;
CREATE USER JaneSmithUser WITHOUT LOGIN;
CREATE USER DavidLeeUser WITHOUT LOGIN;

-- Grant SELECT, INSERT, UPDATE, and DELETE permissions to the users
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers TO JohnDoeUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers TO JaneSmithUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers TO DavidLeeUser;

-- Implement Row level security
CREATE FUNCTION dbo.fn_securitypredicate(@CustomerName AS VARCHAR(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @CustomerName = CONVERT(VARCHAR(100), SESSION_CONTEXT(N'CustomerName'));

-- Create security policy
CREATE SECURITY POLICY RowLevelSecurity
ADD FILTER PREDICATE dbo.fn_securitypredicate(CustomerName)
ON dbo.Customers
WITH (STATE = ON);

-- Set session context for users
EXEC sp_set_session_context @key = N'CustomerName', @value = 'John Doe';
SELECT * FROM Customers where CustomerName = 'John Doe';

EXEC sp_set_session_context @key = N'CustomerName', @value = 'Jane Smith';
SELECT * FROM Customers where CustomerName = 'Jane Smith';

EXEC sp_set_session_context @key = N'CustomerName', @value = 'David Lee';
SELECT * FROM Customers where CustomerName = 'David Lee';

--Backup Database
BACKUP DATABASE [Bookworm Haven] TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.bak' 
WITH INIT, FORMAT;

--Full Recovery model
USE [master];
ALTER DATABASE [Bookworm Haven]
SET RECOVERY FULL;

--create transactional Log
BACKUP LOG [Bookworm Haven]
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.trn'
WITH INIT;

USE master;

-- Restore the full backup with NORECOVERY
RESTORE DATABASE [Bookworm Haven]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.bak'
WITH NORECOVERY;

-- Restore the first transaction log backup with NORECOVERY
RESTORE LOG [Bookworm Haven]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.trn'
WITH NORECOVERY;

-- Restore the second transaction log backup with NORECOVERY
RESTORE LOG [Bookworm Haven]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.trn'
WITH NORECOVERY;

-- Recover to the specific point in time
RESTORE LOG [Bookworm Haven]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.trn'
WITH STOPAT = '2023-08-05T10:43:03', RECOVERY;




--View when timestamp was created
USE msdb;

SELECT
    bs.database_name AS [Bookworm Haven],
    bs.backup_start_date AS BackupStartDate,
    bs.backup_finish_date AS BackupFinishDate,
    bmf.physical_device_name AS BackupFileLocation
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.type = 'L' 
    AND bs.database_name = 'Bookworm Haven' 
ORDER BY bs.backup_finish_date DESC;

RESTORE DATABASE [Bookworm Haven] 
   FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.bak'
   WITH FILE=1, NORECOVERY;  
--Recover timestamp
RESTORE LOG [Bookworm Haven]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Bookworm Haven_FullBackup.bak'
WITH STOPAT = '2023-08-05 10:51:12.000', RECOVERY;


