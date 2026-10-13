-- SQL Window Functions for Northwind Traders (Dataquest guided project)

-- Step 2: Getting to Know the Data
SELECT table_name AS name,
       table_type AS type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type IN ('BASE TABLE', 'VIEW');

-- Step 3: Ranking Employee Sales Performance
WITH employee_sales AS (
    SELECT e.employee_id,
           e.first_name,
           e.last_name,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM employees AS e
    JOIN orders AS o
        ON e.employee_id = o.employee_id
    JOIN order_details AS od
        ON o.order_id = od.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)

SELECT employee_id,
       first_name,
       last_name,
       total_sales,
       RANK() OVER (
           ORDER BY total_sales DESC
       ) AS sales_rank
FROM employee_sales;

-- Step 4: Running Total of Monthly Sales
WITH monthly_sales AS (
    SELECT DATE_TRUNC('month', o.order_date) AS month,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM orders AS o
    JOIN order_details AS od
        ON o.order_id = od.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)

SELECT month,
       total_sales,
       SUM(total_sales) OVER (
           ORDER BY month
       ) AS running_total
FROM monthly_sales
ORDER BY month;

-- Step 5: Month-Over-Month Sales Growth
WITH monthly_sales AS (
    SELECT DATE_TRUNC('month', o.order_date) AS month,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM orders AS o
    JOIN order_details AS od
        ON o.order_id = od.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
),

sales_with_previous AS (
    SELECT month,
           total_sales,
           LAG(total_sales) OVER (
               ORDER BY month
           ) AS previous_month_sales
    FROM monthly_sales
)

SELECT month,
       total_sales,
       previous_month_sales,
       ((total_sales - previous_month_sales) / previous_month_sales) * 100
           AS growth_rate
FROM sales_with_previous
ORDER BY month;

-- Step 6: Identifying High-Value Customers
WITH order_values AS (
    SELECT o.customer_id,
           o.order_id,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS order_value
    FROM orders AS o
    JOIN order_details AS od
        ON o.order_id = od.order_id
    GROUP BY o.customer_id, o.order_id
)

SELECT customer_id,
       order_id,
       order_value,
       CASE
           WHEN order_value > AVG(order_value) OVER ()
               THEN 'Above Average'
           ELSE 'Average/Below Average'
       END AS order_category
FROM order_values
ORDER BY customer_id, order_id;

-- Step 7: Percentage of Sales for Each Category
WITH category_sales AS (
    SELECT c.category_id,
           c.category_name,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM categories AS c
    JOIN products AS p
        ON c.category_id = p.category_id
    JOIN order_details AS od
        ON p.product_id = od.product_id
    GROUP BY c.category_id, c.category_name
)

SELECT category_id,
       category_name,
       total_sales,
       ROUND(
           (total_sales / SUM(total_sales) OVER () * 100)::numeric,
           2
       ) AS sales_percentage
FROM category_sales
ORDER BY sales_percentage DESC;

-- Step 8: Top Products per Category
WITH product_sales AS (
    SELECT p.category_id,
           p.product_id,
           p.product_name,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM products AS p
    JOIN order_details AS od
        ON p.product_id = od.product_id
    GROUP BY p.category_id, p.product_id, p.product_name
),

ranked_products AS (
    SELECT category_id,
           product_id,
           product_name,
           total_sales,
           ROW_NUMBER() OVER (
               PARTITION BY category_id
               ORDER BY total_sales DESC
           ) AS row_number
    FROM product_sales
)

SELECT *
FROM ranked_products
WHERE row_number <= 3
ORDER BY category_id, row_number;
