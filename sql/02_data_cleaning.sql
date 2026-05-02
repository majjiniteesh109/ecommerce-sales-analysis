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
