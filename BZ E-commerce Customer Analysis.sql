/* check if any missing value for each table */

SELECT SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS id_null_count,
       SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS unique_id_null_count,
	   SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_prefix_null_count,
	   SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS city_null_count,
	   SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS state_null_count
  FROM customers;-- no missing value

SELECT SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_prefix_null_count,
       SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS lat_null_count,
	   SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS lng_null_count,
	   SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS city_null_count,
	   SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS state_null_count
  FROM geolocation;-- no missing value

SELECT SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS id_null_count,
       SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS item_id_null_count,
	   SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_null_count,
	   SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_null_count,
	   SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_limit_date_null_count,
	   SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_null_count,
	   SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_value_null_count
  FROM order_items;-- no missing value
 
SELECT SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS id_null_count,
       SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS sequential_null_count,
	   SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS type_null_count,
	   SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS installments_null_count,
	   SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS value_null_count
  FROM order_payments;-- no missing value
 
SELECT SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS category_name_null_count,
       SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS category_name_english_null_count
  FROM product_category_name_translation;-- no missing value

SELECT SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS id_null_count,
       SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_prefix_null_count,
	   SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS city_null_count,
	   SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS state_null_count
  FROM sellers;-- no missing value

SELECT ROUND(CAST(SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS review_id_null_perc,
       ROUND(CAST(SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS order_id_null_perc,
	   ROUND(CAST(SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS score_null_perc,
	   ROUND(CAST(SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS comment_title_null_perc,
	   ROUND(CAST(SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS comment_message_null_perc,
	   ROUND(CAST(SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS creation_date_null_perc,
	   ROUND(CAST(SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS answer_timestamp_null_perc
  FROM order_reviews;
-- comment tile & comment message have missing values
-- We can classify those customers who didn't leave a comment as its own group to do further analysis.

SELECT ROUND(CAST(SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS order_id_null_perc,
       ROUND(CAST(SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS customer_id_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS status_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS purchase_timestamp_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS approved_at_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS delivered_carrier_date_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS delivered_customer_date_null_perc,
	   ROUND(CAST(SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS estimated_delivery_date_null_perc
  FROM orders;
-- the date when payment is approved & order handed over to logistic partner & order delivered to customer have missing values
-- When analyzing the data from a delivery viewpoint, those missing values should be excluded.

SELECT ROUND(CAST(SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS id_null_perc,
       ROUND(CAST(SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS category_name_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS name_length_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS description_length_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS photos_qty_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS weight_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS length_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS height_null_perc,
	   ROUND(CAST(SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(*)*100,2) || '%' AS width_null_perc
  FROM products;
-- category name, the length of the product name and its description and the published photo qty have missing values
-- the weight, length, height and width of the product have missing values 
-- We can classify those products without a photo as its own group to do further analysis.

/* check if any outlier */
 
SELECT MIN(price) AS min_price,
       percentile_disc(0.25) WITHIN GROUP (ORDER BY price) AS q1_price,
	   percentile_disc(0.5) WITHIN GROUP (ORDER BY price) AS q2_price,
	   percentile_disc(0.75) WITHIN GROUP (ORDER BY price) AS q3_price,
       MAX(price) AS max_price,
	   MIN(freight_value) AS min_freight_value,
	   percentile_disc(0.25) WITHIN GROUP (ORDER BY freight_value) AS q1_freight_value,
	   percentile_disc(0.5) WITHIN GROUP (ORDER BY freight_value) AS q2_freight_value,
	   percentile_disc(0.75) WITHIN GROUP (ORDER BY freight_value) AS q3_freight_value,
	   MAX(freight_value) AS max_freight_value
  FROM order_items;
-- The max price is about 50 times higher than the price of the upper percentile, after further investigation, the items  
-- with high price are the products which are more expensive by nature such as houseware and computer.

SELECT MIN(payment_value) AS min_payment_value,
       percentile_disc(0.25) WITHIN GROUP (ORDER BY payment_value) AS q1_payment_value,
	   percentile_disc(0.5) WITHIN GROUP (ORDER BY payment_value) AS q2_payment_value,
	   percentile_disc(0.75) WITHIN GROUP (ORDER BY payment_value) AS q3_payment_value,
       MAX(payment_value) AS max_price
  FROM order_payments;
-- The max payment value is about 80 times higher than that of the upper percentile, after further investigation, some 
-- cusotmers may purchase the same product with multiple quantity in the same one order, causing the high total payment
-- value but it's reasonable

SELECT ord_item.*,
       ord_pay.payment_value,
	   pro_eng.product_category_name_english
  FROM order_items AS ord_item
  LEFT JOIN order_payments AS ord_pay
    ON ord_item.order_id = ord_pay.order_id
  LEFT JOIN (SELECT pro.product_id,
                    pro.product_category_name,
				    pro_tran.product_category_name_english
			   FROM products AS pro
			   LEFT JOIN product_category_name_translation AS pro_tran
				 ON pro.product_category_name = pro_tran.product_category_name) AS pro_eng
    ON ord_item.product_id = pro_eng.product_id
 ORDER BY ord_item.order_id;
-- create a joined table to see which product is sold in which order on which date and at how much price in one go 

/* start the analysis */

-- What are the number of distinct customer & seller each month?

WITH order_detail AS (
	SELECT DISTINCT ord.order_id,
		   cus.customer_unique_id,
	       ord_item.seller_id,
	       DATE_TRUNC('month',ord.order_purchase_timestamp)::date AS transaction_month,
		   ord.order_status
	  FROM orders AS ord
	  LEFT JOIN customers AS cus
		ON ord.customer_id = cus.customer_id
	  LEFT JOIN order_items AS ord_item
        ON ord.order_id = ord_item.order_id)

SELECT transaction_month,
       COUNT(DISTINCT customer_unique_id) AS number_of_unique_customer,
       COUNT(DISTINCT seller_id) AS number_of_unique_seller
  FROM order_detail
 GROUP BY transaction_month
 ORDER BY transaction_month;  

-- What are the number of monthly revenue and monthly order?
-- What are the revenue and order distribution patterns among the states and cities?

SELECT DATE_TRUNC('month',ord.order_purchase_timestamp)::date AS transaction_month,
       cus.customer_state AS customer_state,
	   cus.customer_city AS customer_city,
       ROUND(SUM(ord_pay.payment_value)::NUMERIC,0) AS revenue,
	   COUNT(DISTINCT ord_pay.order_id) AS number_of_order
  FROM order_payments AS ord_pay
  LEFT JOIN orders AS ord
    ON ord_pay.order_id = ord.order_id
  LEFT JOIN customers AS cus
    ON ord.customer_id = cus.customer_id
 GROUP BY transaction_month, customer_state, customer_city
 ORDER BY transaction_month, number_of_order DESC;

-- What's the revenue pattern among all the customers? 

DROP VIEW IF EXISTS customer_revenue; 
CREATE VIEW customer_revenue (customer, revenue)
    AS
SELECT cus.customer_unique_id AS customer,
	   ROUND(SUM(ord_pay.payment_value)::NUMERIC,0) AS revenue
  FROM order_payments AS ord_pay
  LEFT JOIN orders AS ord
    ON ord_pay.order_id = ord.order_id
  LEFT JOIN customers AS cus
	ON ord.customer_id = cus.customer_id
 GROUP BY customer;-- revenue by each customer

SELECT MIN(revenue) AS min_revenue,
	   percentile_disc(0.25) WITHIN GROUP (ORDER BY revenue) AS q1_revenue,
       percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS q2_revenue,
	   percentile_disc(0.75) WITHIN GROUP (ORDER BY revenue) AS q3_revenue,
	   MAX(revenue) AS max_revenue
  FROM customer_revenue;
-- The distribution of customer revenue is positively-skewed

WITH customer_revenue_cumulated AS (
	SELECT customer, 
		   revenue,
		   ROUND(CAST(SUM(revenue) OVER (ORDER BY revenue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUMERIC) / SUM(revenue) OVER()*100,2) || '%' AS cumulated_revenue,
		   ROUND(CAST(COUNT(customer) OVER (ORDER BY revenue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUMERIC) / COUNT(customer) OVER()*100,2) || '%' AS cumulated_number_of_customer
	  FROM customer_revenue
	 ORDER BY revenue)
-- rank the customer by revenue in ascending order and accumulate the number of customer and the revenue

SELECT *
  FROM customer_revenue_cumulated
 WHERE cumulated_number_of_customer LIKE '80.00%';
-- 80% of the total customers account for 46% of the total revenue, meaning that the rest 20% of total customers contribute
-- 54% of the total revenue. We classify those 20% customers as "high revenue customer" and those 80% as "low revenue customer"
-- and do further investigation on whether there's any different dimension b/w these two groups in Tableau.


