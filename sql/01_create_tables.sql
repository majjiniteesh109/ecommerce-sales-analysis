#create database
CREATE DATABASE ecommerce_project;
USE ecommerce_project;

#create empty table 
CREATE TABLE sales (
    transaction_id VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    customer_age VARCHAR(10),
    gender VARCHAR(10),
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    quantiy VARCHAR(10),
    prce VARCHAR(10),
    payment_mode VARCHAR(20),
    purchase_date VARCHAR(20),
    time_of_purchase VARCHAR(20),
    status VARCHAR(20)
);

#load the data to the empty table from the csv file 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#checking the data 
SELECT COUNT(*) FROM sales;
SELECT * FROM sales LIMIT 10;

#data cleaning 

CREATE TABLE sales_clean AS
SELECT * FROM sales;

#change column
ALTER TABLE sales_clean change column quantiy quantity INT ;

ALTER TABLE sales_clean change column prce price DECIMAL(10,2);

#change datatype 

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_clean
SET customer_age = NULL
WHERE customer_age = '';

ALTER TABLE sales_clean
MODIFY customer_age INT;

#date  datatype

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_clean
SET purchase_date = NULL
WHERE purchase_date = '';

UPDATE sales_clean
SET purchase_date = STR_TO_DATE(purchase_date, '%d/%m/%Y');

ALTER TABLE sales_clean
MODIFY purchase_date DATE;

#change datatype to time 
ALTER TABLE sales_clean
MODIFY time_of_purchase TIME;

#gender to m and male as MALE and f AND female as FEMALE
SELECT DISTINCT gender FROM sales_clean;

UPDATE sales_clean
SET gender="FEMALE"
WHERE gender in ("F","female")

UPDATE sales_clean
SET gender="MALE"
WHERE gender in ("M", "male")

#chech gender columns is consitent or not 
select gender from sales_clean;
 
#check all rows as changed or not 
select * from sales_clean;

#update the cc as credit card 

SELECT DISTINCT payment_mode FROM sales_clean;

update sales_clean
set payment_mode="Credit Card"
where payment_mode="CC"

#create the revenue coulmn 

ALTER TABLE sales_clean
ADD COLUMN revenue DECIMAL(10,2);

UPDATE sales_clean
SET revenue = quantity * price;

#updating the revenue to 0 for the cancelled order 
UPDATE sales_clean
SET revenue = 0
WHERE TRIM(LOWER(status)) = 'cancelled';

SELECT status, LENGTH(status)
FROM sales_clean
WHERE status LIKE '%cancel%';

UPDATE sales_clean
SET status = REPLACE(status, '\r', '');

UPDATE sales_clean
SET revenue = 0
WHERE TRIM(LOWER(status)) = 'cancelled';

# add the coulnm for the order_stage for current status and revenue 
ALTER TABLE sales_clean
ADD COLUMN order_stage VARCHAR(20);

UPDATE sales_clean
SET order_stage = 
CASE 
    WHEN status = 'delivered' THEN 'Completed'
    WHEN status IN ('cancelled','returned') THEN 'Failed'
    WHEN status = 'pending' THEN 'In Progress'
END;

update sales_clean 
set revenue=0
where trim(status)="returned"

update sales_clean 
set actual_revenue=0
where trim(status)="pending"


# change the columns name of the revenue as the actuall revenue 

ALTER TABLE sales_clean RENAME COLUMN revenue TO actual_revenue;

# another coumns for Potential Revenue
alter table sales_clean add column revenue decimal(10,2)
ALTER TABLE sales_clean rename column revenue to potential_revenue;

update sales_clean
set revenue=quantity*price

SELECT * FROM sales_clean;

# count orders by status 
select status, count(*) from sales_clean 
group by status;

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




