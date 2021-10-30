## Data

The dataset was download from [Kaggle](https://www.kaggle.com/olistbr/brazilian-ecommerce) and contains data about orders made at a Brazilian e-commerce site, Olist.

**About Olist:**

Olist is the largest department store in Brazilian marketplaces. Olist connects small businesses from all over Brazil to channels without hassle and with a single contract. Those merchants are able to sell their products through the Olist Store and ship them directly to the customers using Olist logistics partners. 

After a customer purchases the product from Olist Store a seller gets notified to fulfill that order. Once the customer receives the product, or the estimated delivery date is due, the customer gets a satisfaction survey by email where he can give a note for the purchase experience and write down some comments.

## Operational layer

My operational layer consists of 8 tables stored in .csv files, covering information of about 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil:

1. *olist_customers_dataset.csv* was loaded into the **“customers”** table and contains information about customers and their location.

2. *olist_order_items_dataset.csv* was loaded into the **“order_items”** table and includes data about the items purchased within each order.

3. *olist_order_payments_dataset.csv* was loaded into the **“payments”** table and includes information about the payment method and value of each order.

4. *olist_order_reviews_dataset.csv* was loaded into the **“reviews”** table and contains data about the reviews on each order written by the customers.

5. *olist_orders_dataset.csv* was loaded into the **“orders”** table and summarizes order details about each order.

6. *olist_products_dataset.csv* was loaded into the **“products”** table and contains product details of the products sold on Olist.

7. *olist_sellers_dataset.csv* was loaded into the **“sellers”** table and includes data about the sellers that fulfilled orders made at Olist.

8. *product_category_name_translation.csv* was loaded into the **“productcat_trans”** table and includes the English translation of the Portuguese category names.

9. Initially, there was a 9th table included in the dataset (*olist_geolocation_dataset.csv*), which I decided to not to load, as it contained data that I did not intend to use in my analytical plan.

The following EER diagram represents the star schema created from the above tables with the **“orders”** table as my main table:

![image-20211030221814211](C:\Users\vargh\AppData\Roaming\Typora\typora-user-images\image-20211030221814211.png)

## Analytics plan & analytical layer

My analytical plan was formulated to address the following aspects of the dataset:

1. Which product categories performed the best in terms of sales in 2018 and what was their corresponding the average customer satisfaction measured by the average review score?

2. Who were the top 10 best performing sellers in San Paolo in terms of sales in the period covered by the dataset?

3. A reporting view on the orders in the electronics product category, containing the most important data on each order (incl. the customer’s unique ID, seller ID, order status, price, payment type, review score). 

   Sample analytical question: how many credit card transactions were executed in the electronics category in 2018?

To answer the two analytical questions about top performing product categories and sellers, as well as to create the reporting view on transactions in the electronics category, the following steps were taken:

-  An analytical layer was created including a set of columns relevant for the analytics plan. (Some columns were not used for creating the three data marts as part of the term project, however, they might be used for more advanced/complex analytical questions in the future.)

- When creating the analytical layer, inner joins were used to connect the tables. As a result, only entries with matching seller, customer and product IDs were kept.

The analytical layer was built on the following star schema:

![image-20211030221932243](C:\Users\vargh\AppData\Roaming\Typora\typora-user-images\image-20211030221932243.png)

## Data marts

The following three data marts were created to address the analytical questions:

1. **topperformer_category:** the aim of the view is to show the top performing product categories by sales and their average customer reviews in 2018. The view contains Category, Sales and Avg_Review_score.

2. **topperformer_sellers:** the goal of the view is to show the top 10 best performing sellers from Sao Paolo by sales and product category. The view contains Seller_ID, Seller_city, Category, Sales, and Avg_Review_score.

3. **reporting_electronics:** the goal of the view is to summarize key data on each order transaction in the electronics product category. It involves Category, Customer_UID, Seller_ID, Price, Review_score, Payment_type, Payment_installments, Order_status and Order_date.