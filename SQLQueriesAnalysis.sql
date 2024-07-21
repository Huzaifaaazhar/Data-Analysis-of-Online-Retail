SELECT SUM(Quantity) AS TotalQuantitySold
FROM [Online Retail];




SELECT COUNT(DISTINCT StockCode) AS UniqueProducts
FROM [Online Retail];




SELECT TOP 10 CustomerID, SUM(Quantity) AS TotalQuantity
FROM [Online Retail]
GROUP BY CustomerID
ORDER BY TotalQuantity DESC;




SELECT FORMAT(InvoiceDate, 'yyyy-MM') AS Month, SUM(Quantity) AS TotalQuantity
FROM [Online Retail]
GROUP BY FORMAT(InvoiceDate, 'yyyy-MM')
ORDER BY Month;




SELECT TOP 1 Description, COUNT(*) AS Frequency
FROM [Online Retail]
GROUP BY Description
ORDER BY Frequency DESC;




SELECT Description, COUNT(InvoiceNo) as Sales, SUM(Quantity * StockCode) AS revenue
FROM [Online Retail]
GROUP BY Description
ORDER BY revenue DESC;




SELECT CustomerID, COUNT(InvoiceNo) AS order_count
FROM [Online Retail]
GROUP BY CustomerID
ORDER BY order_count DESC;




-- Order frequency
SELECT 
    TOP 10 CustomerID, 
    COUNT(InvoiceNo) AS order_count
FROM [Online Retail]
GROUP BY CustomerID
ORDER BY order_count DESC;




-- Order recency
SELECT 
    TOP 10 CustomerID, 
    MAX(InvoiceDate) AS last_order_date
FROM [Online Retail]
GROUP BY CustomerID
ORDER BY last_order_date DESC;





-- Average order value per customer
SELECT 
    Top 10 CustomerID, 
    AVG(Quantity) AS avg_order_value
FROM [Online Retail]
GROUP BY CustomerID
ORDER BY avg_order_value DESC;





-- RFM Analysis-----------------------
--Recency: Days since last order
SELECT 
    TOP 10 CustomerID,
    DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS Recency
FROM [Online Retail]
GROUP BY CustomerID;

-- Frequency: Number of orders
SELECT 
    CustomerID, 
    COUNT(InvoiceNo) AS Frequency
FROM [Online Retail]
GROUP BY CustomerID;

-- Monetary: Total revenue
SELECT 
    CustomerID, 
    SUM(Quantity * StockCode) AS monetary
FROM [Online Retail]
GROUP BY CustomerID;







-- ------------------RFM----------------------------------------------------------------------------------------------------------------
WITH Recency AS (
    SELECT CustomerID, DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS recency
    FROM [Online Retail]
    GROUP BY CustomerID
),
Frequency AS (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS frequency
    FROM [Online Retail]
    GROUP BY CustomerID
),
Monetary AS (
    SELECT CustomerID, Count(InvoiceNo) AS monetary
    FROM [Online Retail]
    GROUP BY CustomerID
)
SELECT 
    R.CustomerID, R.recency, F.frequency, M.monetary
FROM Recency R
JOIN Frequency F ON R.CustomerID = F.CustomerID
JOIN Monetary M ON R.CustomerID = M.CustomerID;






-- Top-performing products by revenue
SELECT 
    Description as Product, 
    COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM [Online Retail]
GROUP BY Description
ORDER BY Total_Orders DESC;





-- Assign cohort month based on first order date
WITH customer_first_order AS (
    SELECT CustomerID, MIN(InvoiceDate) AS first_order_date
    FROM [Online Retail]
    GROUP BY CustomerID
),
cohort_analysis AS (
    SELECT 
        o.CustomerID, FORMAT(c.first_order_date, 'yyyy-MM') AS cohort_month, FORMAT(o.InvoiceDate, 'yyyy-MM') AS order_month, COUNT(o.InvoiceNo) AS order_count,
        SUM(o.Quantity) AS revenue
    FROM [Online Retail] as o
    JOIN customer_first_order c ON o.CustomerID = c.CustomerID
    GROUP BY c.first_order_date, o.InvoiceDate, o.CustomerID
)
SELECT 
    cohort_month, order_month, order_count, revenue
FROM cohort_analysis
ORDER BY cohort_month, order_month;






-- Customers at risk of churning (no orders in the last 6 months)
SELECT 
    CustomerID, 
    MAX(InvoiceDate) AS last_order_date,
    DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS days_since_last_order
FROM [Online Retail]
GROUP BY CustomerID
HAVING DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) > 180
ORDER BY days_since_last_order DESC;






SELECT country, Description,
    Count(InvoiceNo) AS Sales
FROM [Online Retail]
GROUP BY 
    country, Description
ORDER BY  Sales DESC;






SELECT 
    country,
    COUNT(DISTINCT CustomerID) AS customer_count
FROM 
    [Online Retail]
GROUP BY 
    country
ORDER BY 
    customer_count DESC;






SELECT  country, SUM(quantity) / COUNT(DISTINCT InvoiceNo) AS avg_order_value
FROM [Online Retail]
GROUP BY country
ORDER BY avg_order_value DESC;







WITH last_order_dates AS (
    SELECT CustomerID, country, MAX(InvoiceDate) AS last_order_date
    FROM [Online Retail]
    GROUP BY CustomerID, country
),
churned_customers AS (
    SELECT country, CustomerID
    FROM last_order_dates
    WHERE DATEDIFF(DAY, last_order_date, GETDATE()) > 180
)
SELECT country, COUNT(DISTINCT CustomerID) AS churned_customers_count
FROM churned_customers
GROUP BY country
ORDER BY churned_customers_count DESC;






-- Product popularity by country (top product in each country)
SELECT DISTINCT(Country), Description, SUM(quantity) AS total_quantity 
FROM [Online Retail] 
GROUP BY country, Description 
ORDER BY country, total_quantity DESC;







-- Calculate total revenue per customer
SELECT 
    CustomerID,
    SUM(Quantity) AS TotalRevenue
FROM [Online Retail]
GROUP BY CustomerID;




-- Calculate average purchase value per customer
SELECT 
    CustomerID,
    AVG(Quantity) AS AvgPurchaseValue
FROM [Online Retail]
GROUP BY CustomerID;




-- Calculate the number of unique invoices per customer (frequency)
SELECT 
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
FROM [Online Retail]
GROUP BY CustomerID;





---Customer Lifetime Value.
WITH customer_revenue AS (
    SELECT CustomerID, SUM(Quantity) AS TotalRevenue
    FROM [Online Retail]
    GROUP BY CustomerID
),
customer_avg_purchase AS (
    SELECT CustomerID, AVG(Quantity) AS AvgPurchaseValue
    FROM [Online Retail]
    GROUP BY CustomerID
),
customer_frequency AS (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
    FROM [Online Retail]
    GROUP BY CustomerID
),
customer_lifespan AS (
    SELECT CustomerID, DATEDIFF(day, MIN(InvoiceDate), MAX(InvoiceDate)) AS Lifespan
    FROM [Online Retail]
    GROUP BY CustomerID
)
SELECT 
    cr.CustomerID, cr.TotalRevenue, cap.AvgPurchaseValue, cf.PurchaseFrequency, cl.Lifespan,
    (cap.AvgPurchaseValue * cf.PurchaseFrequency * cl.Lifespan) AS CLV
FROM customer_revenue cr
JOIN customer_avg_purchase cap ON cr.CustomerID = cap.CustomerID
JOIN customer_frequency cf ON cr.CustomerID = cf.CustomerID
JOIN customer_lifespan cl ON cr.CustomerID = cl.CustomerID;





-- Top 10 countries by number of transactions
SELECT 
    TOP 10 Country,
    COUNT(*) AS NumberOfTransactions
FROM [Online Retail]
GROUP BY Country
ORDER BY NumberOfTransactions DESC;




-- Sales by StockCode
SELECT 
    Top 10 StockCode,
    SUM(Quantity) AS Total_Quantity
FROM [Online Retail]
GROUP BY StockCode
ORDER BY Total_Quantity DESC;