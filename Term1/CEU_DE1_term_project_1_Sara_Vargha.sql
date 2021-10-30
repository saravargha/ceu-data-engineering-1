-- The dataset on Olist was downloaded from Kaggle: https://www.kaggle.com/olistbr/brazilian-ecommerce 

-- First I created the 'olist' schema
drop schema if exists olist;
create schema olist;
use olist;

show variables like "secure_file_priv";
show variables like "local_infile";

set global local_infile=ON;

---- 1. step: Creating tables and loading data
-- Created table "customers" and loaded data
DROP TABLE IF EXISTS customers;
CREATE TABLE customers 
(customer_id VARCHAR(64) NOT NULL,
customer_unique_id VARCHAR(64),
customer_zip_code VARCHAR(64),
customer_city VARCHAR(64),
customer_state VARCHAR(64),PRIMARY KEY(customer_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state)
;

-- check if data was loaded successfully
select * from customers limit 10;

-- Created table "order_items" and loaded data
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items 
(order_unique_id INT NOT NULL auto_increment,
order_id VARCHAR(64),
order_item_id VARCHAR(64),
product_id VARCHAR(64),
seller_id VARCHAR(64),
shipping_limit_date TIMESTAMP,
price FLOAT,
freight_value FLOAT,
primary key (order_unique_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

-- check if data was loaded successfully
select * from order_items limit 10;

-- created table "payments" and loaded data
DROP TABLE IF EXISTS payments;
CREATE TABLE payments
(payment_unique_id INT NOT NULL auto_increment,
order_id VARCHAR(64),
payment_sequential INT,
payment_type VARCHAR(64),
payment_installments INT,
payment_value FLOAT, 
primary key(payment_unique_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

-- check if data was loaded successfully
select * from payments limit 10;

-- create table "reviews" and load data
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews 
(review_id VARCHAR(64),
order_id VARCHAR(64),
review_score INT,
review_comment_title VARCHAR(64),
review_comment_message VARCHAR(500),
review_creation_date DATE,
review_answer_timestamp TIMESTAMP);

-- Initially, I got Error code 1265 when I tried to load the data. To solve this, I added the following two lines:
SHOW VARIABLES LIKE 'sql_mode';
SET SQL_MODE='';

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id,order_id,review_score,review_comment_title,review_comment_message,review_creation_date,review_answer_timestamp);

-- check if data was loaded successfully
select * from reviews limit 10;

-- create table "orders" and load data
DROP TABLE IF EXISTS orders;
CREATE TABLE orders 
(order_id VARCHAR(64),
customer_id VARCHAR(64),
order_status VARCHAR(64),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,PRIMARY KEY(order_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp, @order_approved_at, @order_delivered_carrier_date, @order_delivered_customer_date, order_estimated_delivery_date)
-- missing values where substitued with null in the following three columns:
set order_approved_at=if(@order_approved_at='',null, @order_approved_at), 
	order_delivered_carrier_date=if(@order_delivered_carrier_date='',null, @order_delivered_carrier_date),
    order_delivered_customer_date=if(@order_delivered_customer_date='',null, @order_delivered_customer_date);
-- check if data was loaded successfully
select * from orders limit 10;

-- create table "products" and load data

DROP TABLE IF EXISTS products;
CREATE TABLE products 
(product_id VARCHAR(64),
product_category_name VARCHAR(300),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT,PRIMARY KEY(product_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id,product_category_name,@product_name_length,@product_description_length,@product_photos_qty,@product_weight_g,@product_length_cm,@product_height_cm,@product_width_cm)
-- as part of data cleaning, missing values were substitued by nulls as follows:
set product_name_length=if(@product_name_lenght='',null, @product_name_length),
	product_description_length=if(@product_description_length='',null, @product_description_length),
    product_photos_qty=if(@product_photos_qty='',null, @product_photos_qty),
	product_weight_g=if(@product_weight_g='',null, @product_weight_g),
    product_length_cm=if(@product_length_cm='',null, @product_length_cm),
    product_height_cm=if(@product_height_cm='',null, @product_height_cm),
    product_width_cm=if(@product_width_cm='',null, @product_width_cm);
 
 -- check if data was loaded successfully
 select * from products limit 10;
 
-- create table "sellers" and load data
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers 
(seller_id VARCHAR(300),
seller_zip_code VARCHAR(64),
seller_city VARCHAR(300),
seller_state VARCHAR(300),PRIMARY KEY(seller_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code, seller_city, seller_state)
;

-- check if data was loaded successfully
select * from sellers limit 10;

-- create table "productcat_trans" and load data
DROP TABLE IF EXISTS productcat_trans;
CREATE TABLE productcat_trans
(product_category_name VARCHAR(255),
product_category_name_eng VARCHAR(255),
PRIMARY KEY(product_category_name));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE productcat_trans
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(product_category_name, product_category_name_eng);

-- check if data was loaded successfully
select * from productcat_trans;

---- 2. step: Write ETL procedure to create analytical layer
DROP PROCEDURE IF EXISTS create_olist_analytics_dw;

DELIMITER $$

CREATE PROCEDURE create_olist_analytics_dw()
BEGIN
	DROP TABLE IF EXISTS olist_analytics;

	CREATE TABLE olist_analytics AS
	SELECT
	   customers.customer_unique_id AS Customer_UID,
       customers.customer_city As Customer_city,
	   customers.customer_state As Customer_state,
       order_items.order_unique_id AS Order_UID, 
	   order_items.price AS Price,
       orders.order_id AS Order_ID, 
       orders.order_status AS Order_status,
       orders.order_purchase_timestamp AS Order_date,
       payments.payment_type AS Payment_type,
       payments.payment_installments AS Payment_installments,
       payments.payment_value AS Payment_value,
	   sellers.seller_id  AS Seller_ID,
	   sellers.seller_city  AS Seller_city,
	   sellers.seller_state As Seller_state,
       productcat_trans.product_category_name_eng AS Category,
       products.product_weight_g AS Weight,
       products.product_photos_qty AS Nr_photos,
       products.product_length_cm AS Length,
       products.product_height_cm AS Height,
       products.product_width_cm AS Width,
       reviews.review_id AS Review_ID,
       reviews.review_score AS Review_score,
       reviews.review_comment_title AS Review_title,
       reviews.review_comment_message AS Review_message,
       reviews.review_creation_date AS Review_creation_date,
       reviews.review_answer_timestamp AS Review_answer_date
	FROM
		orders
	INNER JOIN
		customers USING (customer_id)
    INNER JOIN    
		reviews USING (order_id)
	INNER JOIN
		order_items USING (order_id)
	INNER JOIN
		sellers USING (seller_id)
	INNER JOIN
		products USING (product_id)
	INNER JOIN
		productcat_trans USING (product_category_name)
	INNER JOIN
		payments USING (order_id)
	ORDER BY 
		order_purchase_timestamp;
    
END $$
DELIMITER ;

CALL create_olist_analytics_dw;

---- 3. step: Create data marts for analytics
-- 3.1: Top performing product categories by sales and average review scores in 2018
DROP VIEW IF EXISTS topperformer_category;

CREATE VIEW topperformer_category AS
SELECT Category, SUM(Price) as Sales, AVG(Review_score) as Avg_Review_score
FROM olist_analytics  
WHERE Order_date BETWEEN '2018-01-01 00:00:00' AND '2019-01-01 00:00:00'
GROUP BY Category
ORDER BY Sales desc;

-- check result
select * from topperformer_category limit 10;

-- 2: Top 10 best-performing sellers by sales and grouped by product category from Sao Paolo
DROP VIEW IF EXISTS topperformer_sellers;

CREATE VIEW topperformer_sellers AS
SELECT Seller_ID, Seller_city, Category, sum(Price) as Sales, AVG(Review_score) as Avg_Review_score
FROM olist_analytics
Group by Category
HAVING Seller_city='Sao paulo'
ORDER BY Sales desc
limit 10;

-- check result
Select * from topperformer_sellers;

-- 3 Reporting view on customer orders in the electronics product category
DROP VIEW IF EXISTS reporting_electronics;

CREATE VIEW reporting_electronics AS
SELECT Category, Customer_UID, Seller_ID, Price, Review_score, Payment_type, Payment_installments, Order_status, Order_date
FROM olist_analytics
WHERE Category="electronics"
ORDER BY Order_date;

-- check result
SELECT * FROM reporting_electronics;

-- sample analytical question related to reporting view: how many credit card transactions were executed in the electronics category in 2018?
select count(*)
from reporting_electronics 
where Order_date between '2018-01-01 00:00:00' AND '2019-01-01 00:00:00'
AND Payment_type='credit_card';




