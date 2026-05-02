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





