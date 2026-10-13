-- Customers and Products Analysis Using SQL (Dataquest guided project)

-- Step 3: Scale Model Cars Database
DROP TABLE TableSummary;


CREATE TABLE TableSummary (
    table_name TEXT,
    number_of_attributes INTEGER,
    number_of_rows INTEGER
);

INSERT INTO TableSummary (table_name, number_of_rows, number_of_attributes)
SELECT 'Customers' AS table_name, COUNT(*) AS number_of_rows, (SELECT count(*) FROM pragma_table_info('Customers')) AS number_of_attributes FROM Customers
UNION ALL
SELECT 'Products', COUNT(*), (SELECT count(*) FROM pragma_table_info('Products')) FROM Products
UNION ALL
SELECT 'ProductLines', COUNT(*), (SELECT count(*) FROM pragma_table_info('ProductLines')) FROM ProductLines
UNION ALL
SELECT 'Orders', COUNT(*), (SELECT count(*) FROM pragma_table_info('Orders')) FROM Orders
UNION ALL
SELECT 'OrderDetails', COUNT(*), (SELECT count(*) FROM pragma_table_info('OrderDetails')) FROM OrderDetails
UNION ALL
SELECT 'Payments', COUNT(*), (SELECT count(*) FROM pragma_table_info('Payments')) FROM Payments
UNION ALL
SELECT 'Employees', COUNT(*), (SELECT count(*) FROM pragma_table_info('Employees')) FROM Employees
UNION ALL
SELECT 'Offices', COUNT(*), (SELECT count(*) FROM pragma_table_info('Offices')) FROM Offices;

-- Step 4: Question 1 - Which Products Should We Order More of or Less of?
-- Compute low stock for each product
WITH LowStock AS (
    SELECT 
        products.productCode,
        ROUND(SUM(orderdetails.quantityOrdered) / products.quantityInStock,  2) AS lowStockRatio
    FROM 
        orderDetails, products
    GROUP BY 
        products.productCode
    ORDER BY 
        lowStockRatio ASC
    LIMIT 10
)

-- Compute product performance for each product
, ProductPerformance AS (
    SELECT 
        productCode,
        ROUND(SUM(quantityOrdered * priceEach), 2) AS productPerformance
    FROM 
        OrderDetails
    GROUP BY 
        productCode
    ORDER BY 
        productPerformance DESC
    LIMIT 10
)

-- Combine the two queries
SELECT 
    LowStock.productCode,
    LowStock.lowStockRatio,
    ProductPerformance.productPerformance
FROM 
    LowStock
JOIN 
    ProductPerformance ON LowStock.productCode = ProductPerformance.productCode;

-- Step 5: Question 2 - How Should We Match Marketing and Communication Strategies to Customer Behavior?
SELECT orders.customerNumber,  SUM( orderdetails.quantityOrdered * (orderdetails.priceEach - products.buyPrice)) as profit
FROM orders
JOIN orderdetails ON orders.orderNumber  = orderdetails.orderNumber
JOIN products ON orderdetails.productCode = products.productCode
GROUP BY orders.customerNumber;

-- Step 6: Finding the VIP and Less Engaged Customers
WITH CustomerProfits AS (
    SELECT 
        o.customerNumber, 
        SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
    FROM 
        orderdetails od
    JOIN 
        products p ON od.productCode = p.productCode
    JOIN 
        orders o ON o.orderNumber = od.orderNumber
    GROUP BY 
        o.customerNumber
)
SELECT 
    c.contactLastName, 
    c.contactFirstName, 
    c.city, 
    c.country, 
    cp.profit
FROM 
    CustomerProfits cp
JOIN 
    customers c ON cp.customerNumber = c.customerNumber
ORDER BY 
    cp.profit DESC
LIMIT 5;

-- Step 7: Question 3 - How Much Can We Spend on Acquiring New Customers?
WITH CustomerProfits AS (
    -- Previous CTE to calculate customer profits
    SELECT 
        o.customerNumber, 
        SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
    FROM 
        products p
    JOIN 
        orderdetails od ON p.productCode = od.productCode
    JOIN 
        orders o ON o.orderNumber = od.orderNumber
    GROUP BY 
        o.customerNumber
)

-- Query to compute the average customer profit
SELECT 
    AVG(profit) AS average_customer_profit
FROM 
    CustomerProfits;
