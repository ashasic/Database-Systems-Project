/*The following SQL queries are for the CS4400 Database project. The previous SQL script contains
the table creation and data inserts that we will be running our queries on.*/

-- Drop Views (dependent on base tables)
DROP VIEW IF EXISTS View_Customer_Order_Summary;
DROP VIEW IF EXISTS View_All_Employee_Info;

-- Drop Triggers
DROP TRIGGER IF EXISTS trg_UpdateSaleAMT_AfterInsert;
DROP TRIGGER IF EXISTS trg_ValidateShipmentDates_BeforeInsert;
DROP TRIGGER IF EXISTS trg_DefaultMembershipStatus_BeforeInsert;

-- Drop Procedures
DROP PROCEDURE IF EXISTS GetCustomerOrders;
DROP PROCEDURE IF EXISTS ShowLowStockProducts;

/*Include at least three triggers that suit our project requirements.*/

-- Trigger 1: Update SaleAMT in Orders after insert into OrderDetails
DELIMITER $$
CREATE TRIGGER trg_UpdateSaleAMT_AfterInsert
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET SaleAMT = (
        SELECT SUM(Quantity * PricePerUnit)
        FROM OrderDetails
        WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END $$
DELIMITER ;

-- Trigger 2: Validate Shipment Dates - No ActualDeliveryDate earlier than OrderDate
DELIMITER $$
CREATE TRIGGER trg_ValidateShipmentDates_BeforeInsert
BEFORE INSERT ON Shipments
FOR EACH ROW
BEGIN
    IF NEW.ActualDeliveryDate < NEW.OrderDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: ActualDeliveryDate cannot be before OrderDate.';
    END IF;
END $$
DELIMITER ;

-- Trigger 3: Auto-set MembershipStatus to 'Active' if NULL during Customer Insert
DELIMITER $$
CREATE TRIGGER trg_DefaultMembershipStatus_BeforeInsert
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    IF NEW.MembershipStatus IS NULL THEN
        SET NEW.MembershipStatus = 'Active';
    END IF;
END $$
DELIMITER ;

/*Include at least 2 relational views*/

-- View 1: View_All_Employee_Info - Displays Employee Full Name, Store Location, and Start Date

CREATE VIEW View_All_Employee_Info AS
SELECT 
    E.EmployeeNum,
    CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
    S.Location AS StoreLocation,
    E.StartDate
FROM Employees E
JOIN Store S ON E.StoreID = S.StoreID;

-- View 2: View_Customer_Order_Summary - Displays Customer Full Name, Order ID, and SaleAMT
CREATE VIEW View_Customer_Order_Summary AS
SELECT 
    C.CustomerNum,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    O.OrderID,
    O.SaleAMT
FROM Customers C
JOIN Orders O ON C.CustomerNum = O.CustomerNum;

/* 
Include 5 SQL queries that match our project requirements. At least 3 need to have joins,
at least 2 should involve aggregations, at least 1 should involve a sub query, and at 
least 1 should involve a view.
*/

-- Query 1 (Join): List Orders with Customer Full Name and SaleAMT
SELECT 
    O.OrderID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    O.SaleAMT
FROM Orders O
JOIN Customers C ON O.CustomerNum = C.CustomerNum
ORDER BY O.OrderID;

-- Query 2 (Join): Find Total SaleAMT for Each Store Location
SELECT 
    S.Location AS StoreLocation,
    SUM(O.SaleAMT) AS TotalSales
FROM Orders O
JOIN Store S ON O.Location = S.Location
GROUP BY S.Location
ORDER BY TotalSales DESC;

-- Query 3 (Sub-query): List Products that Have Been Ordered More Than Once
SELECT 
    P.ItemNum,
    P.ItemName
FROM Products P
WHERE P.ItemNum IN (
    SELECT 
        OD.ItemNum
    FROM OrderDetails OD
    GROUP BY OD.ItemNum
    HAVING COUNT(*) > 1
);

-- Query 4 (View): List Customers and Order Info Using View_Customer_Order_Summary
SELECT 
    CustomerName,
    OrderID,
    SaleAMT
FROM View_Customer_Order_Summary
ORDER BY CustomerName;

-- Query 5(Join & Aggregation: Count Number of Employees at Each Store
SELECT 
    S.Location AS StoreLocation,
    COUNT(E.EmployeeNum) AS NumberOfEmployees
FROM Store S
JOIN Employees E ON S.StoreID = E.StoreID
GROUP BY S.Location
ORDER BY NumberOfEmployees DESC;

/*Implement 2 procedures for our project requirements. At least 1 should involve input parameters.*/

-- Procedure 1 (Input Parameter): Get Orders for a Specific Customer
DELIMITER $$
CREATE PROCEDURE GetCustomerOrders(IN custNum INT)
BEGIN
    SELECT 
        O.OrderID,
        O.DateSold,
        O.SaleAMT
    FROM Orders O
    WHERE O.CustomerNum = custNum
    ORDER BY O.DateSold;
END $$
DELIMITER ;

-- Procedure 2: Show Products that Need Restocking
DELIMITER $$
CREATE PROCEDURE ShowLowStockProducts()
BEGIN
    SELECT 
        ItemNum,
        ItemName,
        QuantityInStock
    FROM Products
    WHERE QuantityInStock < 10
    ORDER BY QuantityInStock ASC;
END $$
DELIMITER ;
