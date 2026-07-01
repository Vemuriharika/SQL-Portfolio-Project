CREATE DATABASE superstore_db;

USE superstore_db;

SELECT * FROM super_store;

-- TOP  10 PRODUCTS BY REVENUE (GROUP BY, ORDER BY) -----------

SELECT
Sub_Category,
COUNT(*) AS Orders,
ROUND(SUM(Sales),2) AS Revenue,
ROUND (SUM(Profit)/SUM(Sales)*100,2) AS Profit_Margin
FROM super_store
GROUP BY Sub_Category
ORDER BY Revenue DESC
LIMIT 10;


-- REGIONAL PERFORMANCE (GROUP BY, HAVING)  ---------------
-- Region with > 100k revenue

SELECT
Region,
ROUND(SUM(Sales),2) AS Revenue,
COUNT(DISTINCT Customer_ID) AS Customers,
ROUND(AVG(Sales),2) AS Avg_Order
FROM super_store
GROUP BY Region
HAVING SUM(Sales)> 100000
ORDER BY Revenue DESC;


-- CUSTOMER LIFETIME VALUE (TOP 10 CUSTOMERS) -----------

SELECT
Customer_ID,
COUNT(*) AS Orders,
ROUND(SUM(Sales),2) AS Lifetime_Value,
MAX(Order_Date) AS Last_Order
FROM super_store
GROUP BY Customer_ID
ORDER BY Lifetime_Value DESC
LIMIT 10;


-- Monthly revenue growth ("Window functions")

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(Order_Date, '%m/%d/%Y'), '%Y-%m-01') AS month,
        SUM(Sales) AS monthly_revenue
    FROM super_store
    GROUP BY DATE_FORMAT(STR_TO_DATE(Order_Date, '%m/%d/%Y'), '%Y-%m-01')
)
SELECT 
    month,
    ROUND(monthly_revenue,2) AS Monthly_Revenue,
    ROUND(LAG(monthly_revenue) OVER (ORDER BY month),2) AS prev_month, 
    ROUND(
        100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0),2) AS growth_pct
FROM monthly_sales
ORDER BY month DESC;


-- TOP PRODUCT PER CATEGORY ------------

WITH sub_totals AS (
    SELECT
        Category,
        Sub_Category,
        SUM(Sales) AS Revenue
    FROM super_store
    GROUP BY Category, Sub_Category
),
ranked AS (
    SELECT
        Category,
        Sub_Category,
        ROUND(Revenue,2) AS	Total_Revenue,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS High
    FROM sub_totals
)
SELECT *
FROM ranked
WHERE High = 1;
