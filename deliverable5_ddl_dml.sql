DROP TABLE IF EXISTS ShipmentDetails, Shipments, OrderDetails, Orders, Employees, Customers, Products, Suppliers, Store;

-- Store table
CREATE TABLE Store (
    StoreID INT PRIMARY KEY,
    Location VARCHAR(100)
);

-- Employees table
CREATE TABLE Employees (
    EmployeeNum INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address VARCHAR(100),
    StoreID INT,
    Salary DECIMAL(10, 2),
    StartDate DATE,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);

-- Customers table
CREATE TABLE Customers (
    CustomerNum INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateJoined DATE,
    MembershipStatus VARCHAR(20)
);

-- Products table
CREATE TABLE Products (
    ItemNum INT PRIMARY KEY,
    ItemName VARCHAR(100),
    QuantityInStock INT,
    CostPerUnit DECIMAL(5, 2),
    PricePerUnit DECIMAL(5, 2),
    ItemType VARCHAR(50),
    InStoreLocation VARCHAR(50)
);

-- Suppliers table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    ContactName VARCHAR(100),
    Phone BIGINT
);

-- Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    DateSold DATE,
    SaleAMT DECIMAL(10, 2),
    Location VARCHAR(100),
    CustomerNum INT,
    FOREIGN KEY (CustomerNum) REFERENCES Customers(CustomerNum)
);

-- OrderDetails table
CREATE TABLE OrderDetails (
    OrderID INT,
    ItemNum INT,
    Quantity INT,
    PricePerUnit DECIMAL(5, 2),
    PRIMARY KEY (OrderID, ItemNum),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemNum) REFERENCES Products(ItemNum)
);

-- Shipments table
CREATE TABLE Shipments (
    StoreOrderID INT PRIMARY KEY,
    SupplierID INT,
    StoreID INT,
    OrderDate DATE,
    ExpectedDeliveryDate DATE,
    ActualDeliveryDate DATE,
    OrderStatus VARCHAR(50),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);

-- ShipmentDetails table
CREATE TABLE ShipmentDetails (
    StoreOrderID INT,
    ItemNum INT,
    Quantity INT,
    CostPerUnit DECIMAL(5, 2),
    PRIMARY KEY (StoreOrderID, ItemNum),
    FOREIGN KEY (StoreOrderID) REFERENCES Shipments(StoreOrderID),
    FOREIGN KEY (ItemNum) REFERENCES Products(ItemNum)
);

INSERT INTO Store VALUES 
(1, 'Atlanta'), (2, 'New York'), (3, 'Chicago'), (4, 'Los Angeles'), (5, 'Houston');

-- Employees
INSERT INTO Employees VALUES 
(101, 'John', 'Doe', '123 Main St', 1, 45000, '2022-01-15'),
(102, 'Jane', 'Smith', '456 Oak Ave', 2, 47000, '2022-02-20'),
(103, 'Alice', 'Brown', '789 Pine Rd', 3, 46000, '2022-03-10'),
(104, 'Bob', 'White', '321 Maple Dr', 4, 48000, '2022-04-25'),
(105, 'Carol', 'Davis', '654 Birch Ln', 5, 49000, '2022-05-30');

-- Customers
INSERT INTO Customers VALUES 
(201, 'Tom', 'Wilson', '2023-01-10', 'Active'),
(202, 'Lucy', 'Lee', '2023-02-14', 'Active'),
(203, 'Mark', 'King', '2023-03-22', 'Inactive'),
(204, 'Nina', 'Hall', '2023-04-01', 'Active'),
(205, 'Omar', 'Young', '2023-05-18', 'Active');

-- Products
INSERT INTO Products VALUES 
(301, 'Apples', 100, 0.3, 0.5, 'Fruit', 'Aisle 1'),
(302, 'Bananas', 120, 0.25, 0.4, 'Fruit', 'Aisle 1'),
(303, 'Milk', 60, 1.0, 1.5, 'Dairy', 'Aisle 2'),
(304, 'Bread', 80, 1.2, 1.8, 'Bakery', 'Aisle 3'),
(305, 'Eggs', 90, 1.5, 2.0, 'Dairy', 'Aisle 2');

-- Suppliers
INSERT INTO Suppliers VALUES 
(401, 'Global Foods', 1234567890),
(402, 'Fresh Supply Co.', 2345678901),
(403, 'Daily Essentials', 3456789012),
(404, 'Farm Direct', 4567890123),
(405, 'Urban Grocers', 5678901234);

-- Orders
INSERT INTO Orders VALUES 
(501, '2024-03-10', 25.00, 'Atlanta', 201),
(502, '2024-03-11', 15.00, 'New York', 202),
(503, '2024-03-12', 30.00, 'Chicago', 203),
(504, '2024-03-13', 10.00, 'Los Angeles', 204),
(505, '2024-03-14', 20.00, 'Houston', 205);

-- OrderDetails
INSERT INTO OrderDetails VALUES 
(501, 301, 10, 0.5),
(501, 303, 5, 1.5),
(502, 302, 15, 0.4),
(503, 304, 10, 1.8),
(504, 305, 5, 2.0);

-- Shipments
INSERT INTO Shipments VALUES 
(601, 401, 1, '2024-02-01', '2024-02-03', '2024-02-02', 'Delivered'),
(602, 402, 2, '2024-02-05', '2024-02-07', '2024-02-06', 'Delivered'),
(603, 403, 3, '2024-02-10', '2024-02-12', '2024-02-11', 'Delivered'),
(604, 404, 4, '2024-02-15', '2024-02-17', '2024-02-16', 'Delayed'),
(605, 405, 5, '2024-02-20', '2024-02-22', '2024-02-21', 'Delivered');

-- ShipmentDetails
INSERT INTO ShipmentDetails VALUES 
(601, 301, 50, 0.3),
(602, 302, 60, 0.25),
(603, 303, 40, 1.0),
(604, 304, 30, 1.2),
(605, 305, 45, 1.5);

--

INSERT INTO Customers(CustomerNum, FirstName, LastName, DateJoined, MembershipStatus)
VALUES
  (1, 'Alice', 'Smith',   '2025-04-01','Active'),
  (2, 'Bob',   'Jones',   '2025-04-02','Active');

INSERT INTO Products(ItemNum, ItemName, QuantityInStock, CostPerUnit, PricePerUnit, ItemType, InStoreLocation)
VALUES
  (101, 'Widget',       50,  2.00, 4.00, 'Gadget', 'A1'),
  (102, 'Gizmo',        30,  3.00, 6.00, 'Gadget', 'A2'),
  (103, 'Doohickey',    20,  1.50, 3.50, 'Accessory','B1');

INSERT INTO Orders(OrderID, DateSold, SaleAMT, Location, CustomerNum)
VALUES
  (1, '2025-04-15',  16.00, 'Downtown', 1),
  (2, '2025-04-16',   8.00, 'Downtown', 2);

INSERT INTO OrderDetails(OrderID, ItemNum, Quantity, PricePerUnit)
VALUES
  (1, 101, 2, 4.00),   -- Alice buys 2 Widgets
  (1, 102, 1, 6.00),   -- Alice buys 1 Gizmo
  (2, 101, 1, 4.00),   -- Bob buys 1 Widget
  (2, 103, 1, 3.50);   -- Bob buys 1 Doohickey
  
  --
  
  INSERT INTO Customers (CustomerNum, FirstName, LastName, DateJoined, MembershipStatus)
VALUES
  (3, 'Charlie', 'Brown', '2025-04-03', 'Active'),
  (4, 'Dana',    'White', '2025-04-04', 'Active');

-- 6) More Products
INSERT INTO Products (ItemNum, ItemName, QuantityInStock, CostPerUnit, PricePerUnit, ItemType, InStoreLocation)
VALUES
  (104, 'Thingamajig', 40, 2.50, 5.00, 'Gadget',    'A3'),
  (105, 'Whatsit',     15, 1.00, 2.50, 'Accessory','B2');

INSERT INTO Orders (OrderID, DateSold, SaleAMT, Location, CustomerNum)
VALUES
  (3, '2025-04-17', 29.00, 'Downtown', 1),  -- 3×4.00 + 2×6.00 + 1×5.00
  (4, '2025-04-18', 28.00, 'Downtown', 2),  -- 3×6.00 + 2×5.00
  (5, '2025-04-19', 11.00, 'Downtown', 3);  -- 2×3.50 + 1×4.00

INSERT INTO OrderDetails (OrderID, ItemNum, Quantity, PricePerUnit)
VALUES
  (3, 101, 3, 4.00),   -- Widget
  (3, 102, 2, 6.00),   -- Gizmo
  (3, 104, 1, 5.00),   -- Thingamajig

  (4, 102, 3, 6.00),   -- Gizmo
  (4, 104, 2, 5.00),   -- Thingamajig
  (5, 103, 2, 3.50),   -- Doohickey
  (5, 101, 1, 4.00);   -- Widget