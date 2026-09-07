-- Maincrafts Data Analytics & Business Intelligence - Task 2
-- Dataset: synthetic sales/orders + customers created for this submission
-- Compatible with MySQL 8+ and SQLite with minor type/import adjustments.

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    Region VARCHAR(30) NOT NULL,
    Segment VARCHAR(30) NOT NULL
);

CREATE TABLE Orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Product_Category VARCHAR(50) NOT NULL,
    Sub_Category VARCHAR(50) NOT NULL,
    Sales DECIMAL(12,2) NOT NULL,
    Quantity INT NOT NULL,
    Profit DECIMAL(12,2) NOT NULL,
    Discount DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

-- After creating the tables, load data from data/customers.csv and data/orders.csv
-- using your SQL client's CSV import feature.
-- The analysis queries below can then be executed directly.

-- 1. INNER JOIN: combine Orders and Customers
SELECT
    o.Order_ID,
    o.Order_Date,
    c.Customer_Name,
    c.Region,
    c.Segment,
    o.Product_Category,
    o.Sales,
    o.Profit,
    o.Quantity,
    o.Discount
FROM Orders o
INNER JOIN Customers c
    ON o.Customer_ID = c.Customer_ID;

-- 2. Total Sales by Region
SELECT
    c.Region,
    SUM(o.Sales) AS Total_Sales
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region
ORDER BY Total_Sales DESC;

-- 3. Profit Margin by Category
SELECT
    Product_Category,
    SUM(Profit) / NULLIF(SUM(Sales), 0) AS Profit_Margin
FROM Orders
GROUP BY Product_Category
ORDER BY Profit_Margin DESC;

-- 4. Monthly Sales Trend
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Sales) AS Monthly_Sales
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Year, Month;

-- 5. Top 5 Customers by Revenue
SELECT
    c.Customer_Name,
    SUM(o.Sales) AS Total_Revenue
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 5;

-- 6. Sales by Region and Segment
SELECT
    c.Region,
    c.Segment,
    SUM(o.Sales) AS Total_Sales
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region, c.Segment
ORDER BY c.Region, Total_Sales DESC;

-- 7. Average Order Value
SELECT
    SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0) AS Average_Order_Value
FROM Orders;

-- 8. Discount vs profitability
SELECT
    Discount,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Profit) / NULLIF(SUM(Sales), 0) AS Profit_Margin
FROM Orders
GROUP BY Discount
ORDER BY Discount;

-- 9. Most valuable customer segment
SELECT
    c.Segment,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit,
    SUM(o.Profit) / NULLIF(SUM(o.Sales), 0) AS Profit_Margin
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Segment
ORDER BY Total_Sales DESC;

-- 10. Category + Region comparison
SELECT
    c.Region,
    o.Product_Category,
    SUM(o.Sales) AS Sales,
    SUM(o.Profit) AS Profit
FROM Orders o
JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region, o.Product_Category
ORDER BY c.Region, Sales DESC;
