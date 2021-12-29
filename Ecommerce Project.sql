/* look up the basic info. of the dataset */

SELECT table_name, 
	   column_name,
	   data_type
  FROM information_schema.columns
 WHERE table_schema = 'public'; -- check the column name and data type of the table

SELECT COUNT(*)
  FROM ecommerce; -- check the total row number of the table
  
SELECT SUM(CASE WHEN invoiceno IS NULL THEN 1 ELSE 0 END) AS mis_invoiceno,
	   SUM(CASE WHEN stockcode IS NULL THEN 1 ELSE 0 END) AS mis_stockcode,
	   SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS mis_description,
	   SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS mis_quantity,
	   SUM(CASE WHEN invoicedate IS NULL THEN 1 ELSE 0 END) AS mis_invoicedate,
	   SUM(CASE WHEN unitprice IS NULL THEN 1 ELSE 0 END) AS mis_unitprice,
	   SUM(CASE WHEN customerid IS NULL THEN 1 ELSE 0 END) AS mis_customerid,
	   SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS mis_country
  FROM ecommerce; -- check the number of missing value in each table column; only description and customerid have NULL

/* deal with the missing value */

-- tackle customerid first
SELECT invoiceno
  FROM ecommerce
 WHERE customerid IS NULL; --get the invoiceno list whose customerid is NULL

SELECT invoiceno
  FROM ecommerce
 WHERE invoiceno IN (SELECT invoiceno
      				   FROM ecommerce
     				  WHERE customerid IS NULL) AND customerid IS NOT NULL;
-- Select the invoiceno from the original table and put the previous invoiceno list into the where 
-- clause with customerid being NOT NULL. Since the query result returns no row, we can assure that 
-- the invoiceno column contains only NULL in customerid when one of its corresponding customerid rows is NULL.
-- Hence, we classify those transactions whose customerid have NULL as the transaction made by non-registered customer.

-- then tackle description
SELECT stockcode
  FROM ecommerce
 WHERE description IS NULL; --get the stockcode list whose description is NULL

SELECT stockcode
  FROM ecommerce
 WHERE stockcode IN (SELECT stockcode
      				   FROM ecommerce
     				  WHERE description IS NULL) AND description IS NOT NULL;
-- The same verifying method is applied to the column description.However, since the query result does return rows, it means
-- that a stockcode may contain both NULL and normal value at the same time.

SELECT ROUND(CAST((SELECT COUNT(*)
	      	   		 FROM ecommerce
	          		WHERE description IS NULL) AS NUMERIC) / COUNT(*)*100,2) || '%' AS null_description_ratio
  FROM ecommerce;-- Rows with NULL description account for 0.27% of the total dataset in terms of transaciton line item.

SELECT MIN(unitprice) AS min_unitprice,
 	   MIN(quantity) AS min_quantity,
	   MAX(unitprice) AS max_unitprice,
	   MAX(quantity) AS max_quantity
  FROM ecommerce
 WHERE description IS NULL;
-- The unitprice of all the transaction with NULL description is 0. We further check the proportion of the 
-- quantity to the total transaction quantity.
 
SELECT ROUND(CAST((SELECT SUM(ABS(quantity))
	      	   		 FROM ecommerce
	          		WHERE description IS NULL) AS NUMERIC) / SUM(ABS(quantity))*100,2) || '%' AS null_description_qty_ratio
  FROM ecommerce;-- Rows with NULL description account for 1.28% of the total dataset in terms of transaciton quantity.

DROP VIEW IF EXISTS ecommerce_no_null CASCADE;

CREATE VIEW ecommerce_no_null (invoiceno, stockcode, description, quantity, invoicedate, unitprice, new_customerid, country)
    AS
SELECT invoiceno,
       stockcode,
	   description,
	   quantity,
	   invoicedate,
	   unitprice,
	   COALESCE(customerid,'non-registered customer') AS new_customerid,
	   country
  FROM ecommerce
 WHERE description IS NOT NULL;
-- Since the transactions with NULL description only account for a small portion of the dataset, we exclude those transactions
-- from our data and replace NULL in the customerid with 'non-registered customer' and then store the new data into a View
-- called "ecommerce_no_null".

/* examine the distribution of the data in terms of price and quantity */

SELECT MIN(quantity) AS min_quantity,
	   MAX(quantity) AS max_quantity,
	   MIN(unitprice) AS min_unitprice,
	   MAX(unitprice) AS max_unitprice
  FROM ecommerce_no_null;
-- Both the quantity and unitprice have extreme min. & max. value, which requires a further investigation
	   
SELECT *
  FROM ecommerce_no_null
 WHERE unitprice < 0 ;-- only two transactions with unitprice less than 0, which are records for bad debt adjustment

SELECT *
  FROM ecommerce_no_null
 WHERE unitprice >= 0 
 ORDER BY unitprice DESC;
-- We see high unitprice under several different stockcodes which are not related to direct product selling.
-- Our analysis focuses on the performace driven by the direct product selling of this UK-based online retailer, so we need to 
-- decide what kind of stockcode should be included in our data pool.

SELECT LENGTH(stockcode) AS stockcode_by_length,
       COUNT(*) AS stockcode_by_length_count
  FROM ecommerce_no_null
 GROUP BY LENGTH(stockcode)
 ORDER BY stockcode_by_length;
-- We first categorize those stockcodes based on their length and realize that most of our data have stockcodes with either 
-- 5 or 6 digits which are the product codes uniquely assigned to each distinct product.
-- For the remaining stockcode_by_length with digit other than 5 and 6, we follow the below rule "valid invoiceno" to examine
-- them one by one to see whether it is valid or not.

-- valid invoiceno with one item:
-- Since the dataset contains cancellation and discount orders which have negative quantity and positive unitprice, here
-- defines the valid invoiceno as below.
-- (1) the stockcode of the item should be valid AND
-- (2) the total quantity should be greater than 0 and the total price of this invoiceno should also be greater than 0 OR
-- (3) the total quantity should be less than 0 and the total price of this invoiceno should also be less than 0

-- valid invoiceno with two or more items:
-- If the invoiceno contains two or more items, here defines the valid invoiceno as below 
-- (1) at lease one of the items should have valid stockcode AND
-- (2) the total quantity should be greater than 0 and the total price of this invoiceno should also be greater than 0 OR
-- (3) the total quantity should be less than 0 and the total price of this invoiceno should also be less than 0

-- Under this analysis, the definition of "valid" here is that the stockcode should be related to the direct product selling 
-- including sales from 3rd party channels such as Amazon or Ebay or from manual checkout, or the discount, rather than the 
-- stockcode of samples, product damages or bank charge...etc. which are not related to direct product selling.

-- After examination, a valid stockcode should meet one of the following criteria
-- (1) length of 5 or 6 or 7 digits
-- (2) starting with string 'DCG' or 'gift'
-- (3) being 'M' or 'D'

-- stockcode definition table 
-- M: manual checkout
-- B: adjust bad debt
-- S: samples
-- D: discount
-- C2: carriage
-- DOT: dotcom postage
-- POST: postage
-- CRUK: CRUK commission
-- PADS: pads to match all cushions
-- AMAZONFEE: Amazon fee
-- BANK CHARGES: bank charges

DROP VIEW IF EXISTS valid_transaction CASCADE;
DROP VIEW IF EXISTS invoicelist_one_item CASCADE;
DROP VIEW IF EXISTS invoicelist_more_than_one_item CASCADE;
DROP VIEW IF EXISTS invoicelist_with_valid_stock_more_than_one_item CASCADE;

CREATE VIEW invoicelist_one_item (invoiceno)
	AS
SELECT invoiceno
  FROM ecommerce_no_null
 GROUP BY invoiceno
HAVING (COUNT(*) = 1 AND SUM(quantity) > 0 AND SUM(unitprice * quantity) >0) OR  
       (COUNT(*) = 1 AND SUM(quantity) < 0 AND SUM(unitprice * quantity) < 0);
-- create a view containing invoiceno list whose transaction item is 1

CREATE VIEW invoicelist_more_than_one_item (invoiceno)
	AS 
SELECT invoiceno
  FROM ecommerce_no_null
 GROUP BY invoiceno
HAVING (COUNT(*) > 1 AND SUM(quantity) > 0 AND SUM(unitprice * quantity) > 0) OR
       (COUNT(*) > 1 AND SUM(quantity) < 0 AND SUM(unitprice * quantity) < 0);
-- create a view containing invoiceno list whose transaction item is more than 1 

CREATE VIEW invoicelist_with_valid_stock_more_than_one_item (invoiceno)
	AS 
SELECT invoiceno
  FROM ecommerce_no_null
 WHERE invoiceno IN (SELECT invoiceno FROM invoicelist_more_than_one_item)
 GROUP BY invoiceno
HAVING SUM(CASE WHEN LENGTH(stockcode) IN (5,6,7) THEN 1
				WHEN stockcode LIKE 'DCG%' THEN 1
				WHEN stockcode LIKE 'gift%' THEN 1
				WHEN stockcode = 'M' THEN 1
		        WHEN stockcode = 'D' THEN 1
				ELSE 0 END) > 0;
-- put the invoiceno list from the VIEW "invoicelist_more_than_one_item" into the WHERE clause and put the criteria of valid 
-- stockcode into the HAVING clause to get another invoiceno list of interest and then store it in a new VIEW
-- called "invoicelist_with_valid_stock_more_than_one_item"

CREATE VIEW valid_transaction (invoiceno, stockcode, description, quantity, invoicedate, unitprice, new_customerid, country)
    AS
WITH valid_transaction_one_item AS (
	SELECT *
	  FROM ecommerce_no_null
	 WHERE invoiceno IN (SELECT invoiceno FROM invoicelist_one_item) AND
		   (LENGTH(stockcode) IN (5,6,7) OR
		   stockcode LIKE 'DCG%' OR 
		   stockcode LIKE 'gift%' OR
		   stockcode = 'M' OR
		   stockcode = 'D')),
-- put the invoiceno list from the VIEW "invoicelist_one_item" into the WHERE clause along with the criteria of valid 
-- stockcode to get the 1st part of our valid transaction data

valid_transaction_more_than_one_item AS (
	SELECT *
	  FROM ecommerce_no_null
	 WHERE invoiceno IN (SELECT invoiceno FROM invoicelist_with_valid_stock_more_than_one_item))
-- put the invoiceno list from the VIEW "invoicelist_with_valid_stock_more_than_one_item" into the WHERE clause to get 
-- the 2nd part of our valid transaction data

SELECT *
  FROM valid_transaction_one_item
 UNION
SELECT *
  FROM valid_transaction_more_than_one_item;
-- Unify the 1st and 2nd part of valid transaciton data and store the resulting query into a View called "valid_transaction"

SELECT MIN(quantity) AS min_quantity,
	   MAX(quantity) AS max_quantity,
	   MIN(unitprice) AS min_unitprice,
	   MAX(unitprice) AS max_unitprice
  FROM valid_transaction;					 
-- Note that most of the customers are wholesalers so it's normal to see high order quantity purchased or returned.
-- Now both the unitprice and quantity look reasonable


/* Exploratory Analysis */

SELECT country,
	   date_trunc('month', invoicedate)::date AS month,
	   ROUND(SUM(unitprice * quantity)::NUMERIC,2) AS revenues,
       COUNT(DISTINCT invoiceno) AS orders
  FROM valid_transaction
 GROUP BY country, month
 ORDER BY country, month;-- total revenues & orders in each month by country 


SELECT country,
	   ROUND(SUM(unitprice * quantity)::NUMERIC,2) AS revenues,
       COUNT(DISTINCT invoiceno) AS orders,
	   ROUND((SUM(unitprice * quantity) / COUNT(DISTINCT invoiceno))::NUMERIC,2) AS revenue_per_order
  FROM valid_transaction
 GROUP BY country
 ORDER BY revenue_per_order DESC;-- total revenues & orders & revenue_per_order by country 
 

SELECT country,
	   CASE WHEN new_customerid = 'non-registered customer' THEN new_customerid
	   	    ELSE 'registered customer' END AS customer_type,
       ROUND(SUM(unitprice * quantity)::NUMERIC,2) AS revenues,
	   COUNT(DISTINCT invoiceno) AS orders,
	   ROUND((SUM(unitprice * quantity) / SUM(SUM(unitprice * quantity)) OVER (PARTITION BY country) * 100)::NUMERIC,2) || '%' AS revenue_proportion,
	   ROUND((COUNT(DISTINCT invoiceno) / SUM(COUNT(DISTINCT invoiceno)) OVER (PARTITION BY country) * 100)::NUMERIC,2) || '%' AS order_proportion
  FROM valid_transaction
 GROUP BY country, customer_type
 ORDER BY country;-- total revenues & orders by different customer types by country

DROP VIEW IF EXISTS hotsaleproduct_by_country_month;

CREATE VIEW hotsaleproduct_by_country_month (country, month, stockcode, description, revenues, orders, ranking)
    AS
WITH product_ranking AS (
	SELECT country,
		   date_trunc('month', invoicedate)::date AS month,
		   stockcode,
		   ROUND(SUM(quantity*unitprice)::NUMERIC, 2) AS revenues,
	       SUM(quantity) AS orders,
		   RANK() OVER (PARTITION BY country, date_trunc('month', invoicedate)::date ORDER BY SUM(quantity) DESC, SUM(quantity*unitprice) DESC) AS ranking
	  FROM valid_transaction
	 WHERE LENGTH(stockcode) IN (5,6,7) OR
		   stockcode LIKE 'DCG%' OR 
		   stockcode LIKE 'gift%'
	 GROUP BY country, month, stockcode
	 ORDER BY country, month, ranking)
-- each stockcode is ranked first by the quantity sold then by the revenue generated in each month within each country 

SELECT DISTINCT pro.country, 
	   pro.month,
	   pro.stockcode,
       val.description,
	   pro.revenues,
	   pro.orders,
	   pro.ranking
  FROM product_ranking AS pro
 INNER JOIN (SELECT date_trunc('month', invoicedate)::date AS month, 
			 		*
  			   FROM valid_transaction) AS val
    ON pro.stockcode = val.stockcode AND pro.country = val.country AND pro.month = val.month
 WHERE pro.ranking IN (1,2,3)
 ORDER BY pro.country, pro.month, pro.ranking;
-- pick up the top 3 popular stocks by country by month and add on the description column by self-join


/* Add on additional columns and export as .csv file to do further analysis & visualization in Tableau */

SELECT *,
	   date_part('year', invoicedate) AS year,
	   date_part('month', invoicedate) AS month,
	   date_part('week', invoicedate) AS week,
	   date_part('day', invoicedate) AS day,
	   to_char(invoicedate,'FMDay') AS name_of_day,
	   date_part('hour', invoicedate) AS hour,
	   CASE WHEN country IN ('United Kingdom') THEN country
			WHEN country IN ('Czech Republic', 'Poland') THEN 'Eastern Europe'
			WHEN country IN ('Denmark', 'Channel Islands', 'Finland', 'Iceland', 'EIRE', 'Lithuania', 'Norway', 'Sweden') THEN 'Northern Europe'
			WHEN country IN ('Greece', 'Italy', 'Malta', 'Portugal', 'Serbia', 'Spain') THEN 'Southern Europe'
			WHEN country IN ('Austria', 'Belgium', 'France', 'Germany', 'Netherlands', 'Switzerland') THEN 'Western Europe'
			ELSE 'Others' END AS region
  FROM valid_transaction
-- Add columns to store the different parts of invoicedate and create a "region" column to categorize each European country
-- into the corresponding region defined by the United Nation (https://unstats.un.org/unsd/methodology/m49/). Since the 
-- majority of our data occured in United Kingdom, we separate United Kingdom into its own region and group the other counties
-- into the region "Others".


