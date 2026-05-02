#KPI layer 
#01 total orders 
SELECT COUNT(*) AS total_orders FROM sales_clean;

#02 total potentaial revenue 
SELECT SUM(potential_revenue) AS total_potential_revenue
FROM sales_clean;

#03 total actual revenue
SELECT SUM(actual_revenue) AS actual_revenue
FROM sales_clean;

#04 Revenue Leakage
SELECT 
SUM(potential_revenue) - SUM(actual_revenue) AS revenue_leakage
FROM sales_clean;

#05 success rate 
SELECT 
(COUNT(CASE WHEN status = 'delivered' THEN 1 END) * 100.0) / COUNT(*) 
AS success_rate
FROM sales_clean;

#06 Failure Rate
SELECT 
(COUNT(CASE WHEN status IN ('cancelled','returned') THEN 1 END) * 100.0) / COUNT(*) 
AS failure_rate
FROM sales_clean;

#07 pending rate 
SELECT 
(COUNT(CASE WHEN status = 'pending' THEN 1 END) * 100.0) / COUNT(*) 
AS pending_rate
FROM sales_clean;


#DIMENSION ANALYSIS

#01 Product-Level Leakage
SELECT 
product_name,
SUM(potential_revenue) AS potential,
SUM(actual_revenue) AS actual,
SUM(potential_revenue - actual_revenue) AS leakage
FROM sales_clean
GROUP BY product_name
ORDER BY leakage DESC;

#02Customer-Level Analysis
SELECT 
customer_name,
SUM(actual_revenue) AS total_spent,
COUNT(*) AS total_orders
FROM sales_clean
GROUP BY customer_name
ORDER BY total_spent DESC;

#found the blank in the paymnet_mode 

select distinct payment_mode from sales_clean;
SELECT payment_mode, COUNT(*) 
FROM sales_clean
GROUP BY payment_mode;

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_clean
SET payment_mode = 'Unknown'
WHERE payment_mode IS NULL OR TRIM(payment_mode) = '';

#03Payment Mode Analysis
select payment_mode , 
sum(actual_revenue) as revenue,
COUNT(*) as orders
from sales_clean
group by payment_mode
order by revenue desc;

#04 monthly tread 
SELECT 
YEAR(purchase_date) AS year,
MONTH(purchase_date) AS month,
SUM(actual_revenue) AS revenue
FROM sales_clean
GROUP BY year, month
order by year, month ;

#05 Time of Purchase Analysis
SELECT 
HOUR(time_of_purchase) AS hour,
COUNT(*) AS total_orders
FROM sales_clean
GROUP BY hour
ORDER BY total_orders desc;

#06 top products with highh revenue 
select product_category, sum(actual_revenue) as product_revenue
from sales_clean
group by product_category
order by product_revenue desc;

