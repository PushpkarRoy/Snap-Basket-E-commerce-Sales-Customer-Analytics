CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(50),
email VARCHAR(100),
location VARCHAR(50),
signup_date DATE 
)

CREATE TABLE order_items (
order_item_id INT,
order_id INT,
product_id INT,
quantity INT,
discount_applied FLOAT,
price FLOAT,
item_total FLOAT
)

CREATE TABLE orders (
order_id INT,
customer_id INT,
order_date DATE,
order_status VARCHAR(50),
payment_method VARCHAR(50)
)

CREATE TABLE products(
product_id INT,
product_name VARCHAR(50),
category VARCHAR(50),
price FLOAT,
stock_quantity INT
)

CREATE TABLE reviews (
review_id INT,
product_id INT,
customer_id INT,
rating INT,
review_date DATE,
review_text VARCHAR(200)
)

SELECT * FROM customers 
SELECT * FROM order_items
SELECT * FROM orders 
SELECT * FROM products 
SELECT * FROM reviews 

-- 🔍 Customer Insights & Segmentation

-- Q1 Find the total number of customers by city. 

SELECT 
  location AS city, 
  COUNT(customer_name) AS total_customer
FROM customers 
GROUP BY location 
ORDER BY total_customer DESC;

-- Q2 Count how many customers signed up in the last 3 months.

SELECT COUNT(customer_id) AS total_customer
FROM (
	SELECT * 
	FROM customers   
	WHERE signup_date  IN (
		SELECT signup_date 
		FROM customers 
		WHERE signup_date BETWEEN '2025-04-01' AND '2025-06-30'
		ORDER BY signup_date ASC))

---------------------- OR---------------------------------------

SELECT COUNT(signup_date) AS total_customer
FROM customers 
WHERE signup_date >= CURRENT_DATE - INTERVAL '3 Months'

-- Q3 Identify top 5 most active customers by number of orders.

SELECT COUNT(order_id) AS total_order, o.customer_id, c.customer_name 
	FROM customers AS c
	JOIN orders AS o
	ON c.customer_id = o.customer_id 
GROUP BY o.customer_id, c.customer_name 
ORDER BY total_order DESC
LIMIT 5 

-- Q4 Find customers who haven’t placed any orders.

SELECT COUNT(name) total_customers 
FROM (
	SELECT c.customer_id, c.customer_name AS name 
	FROM customers AS c
	LEFT JOIN orders AS o
	ON c.customer_id = o.customer_id 
	WHERE o.customer_id IS NULL ) AS x

-- Q5 List customers who have ordered more than 5 times in total.

SELECT COUNT(order_id) AS total_order, c.customer_id, c.customer_name AS name
FROM customers AS c
JOIN orders  AS o
ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(order_id) >= 5
ORDER BY total_order DESC

-- 🛍 Product Performance & Pricing

-- Q6 Find the 10 most expensive products by category.

SELECT * 
FROM (
	SELECT *,
	RANK() OVER(PARTITION BY category ORDER BY price DESC ) AS ranking
	FROM products ) AS x
WHERE ranking <= 10 

-- Q7 Show average price of products in each category.

SELECT category, 
         ROUND(AVG(price):: NUMERIC, 2) AS Avg_price 
FROM products 
GROUP BY category 

-- Q8 Identify products with no stock left.

SELECT * 
FROM products 
WHERE stock_quantity = 0 

SELECT 
    COUNT(*) AS out_of_stock_count
FROM products
WHERE stock_quantity = 0;

-- Q9 List all products that were never ordered.

SELECT 
    p.product_id, 
    p.product_name
FROM products AS p
LEFT JOIN order_items AS ot 
    ON p.product_id = ot.product_id
WHERE ot.product_id IS NULL;

-- Q10 Show products with highest average rating.


SELECT ROUND(AVG(avg_rating),2) AS company_avg_rating
FROM (
SELECT r.product_id, p.product_name, ROUND(AVG(r.rating)::NUMERIC, 2) AS avg_rating
FROM products AS p
JOIN reviews AS r
ON p.product_id = r.product_id 
GROUP BY r.product_id, p.product_name
ORDER BY Avg_rating DESC ) AS x 


--  📈 Sales & Revenue Analysis 

-- Q11 Calculate total revenue generated from all orders.

SELECT SUM(revenue) AS total_revenue 
FROM (
SELECT ot.product_id, p.product_name, ROUND(SUM(item_total):: NUMERIC ,2 ) AS revenue 
FROM order_items AS ot
JOIN products AS p
ON ot.product_id = p.product_id 
GROUP BY ot.product_id, p.product_name ) AS x


-- Q12  Calculate revenue generated per product (sorted high to low).

SELECT ot.product_id, p.product_name,  ROUND(SUM(ot.item_total):: NUMERIC , 2) AS Total_revenue 
FROM order_items AS ot
JOIN products AS p
ON ot.product_id = p.product_id 
GROUP BY ot.product_id, p.product_name
ORDER BY total_revenue DESC

-- Q13  Find total revenue per category.

SELECT p.category, ROUND(SUM(item_total):: NUMERIC, 2) AS Total_revenue 
FROM products AS p
JOIN order_items AS ot
ON p.product_id = ot.product_id 
GROUP BY p.category
ORDER BY total_revenue DESC

-- Q14  Calculate total revenue for each payment method.

SELECT 
     o.payment_method, 
	 ROUND(SUM(item_total)::NUMERIC,2 ) AS Total_revenue, 
     ROUND(SUM((ot.item_total) / (SELECT SUM(item_total) FROM order_items) * 100)::NUMERIC ,2 ) AS percentage
FROM orders AS o
JOIN order_items AS ot
ON o.order_id = ot.order_id 
GROUP BY o.payment_method 
ORDER BY Total_revenue DESC


SELECT 

-- Q15 Determine the average discount given overall.

SELECT ROUND(AVG(discount_applied):: NUMERIC,2) AS avg_discount
FROM order_items 
	   
-- 📅 Time-Based & Trend Questions

-- Q16 Find number of orders placed per month.

SELECT EXTRACT( MONTH FROM order_date) AS Months, COUNT(order_id)
FROM orders 
GROUP BY months 
ORDER BY months ASC


-- Q17 What was the highest sales day in the last 6 months?

SELECT order_date, COUNT(order_id) AS Todays_sale
FROM orders 
WHERE order_date >= CURRENT_DATE - INTERVAL '6 Months'
GROUP BY order_date
ORDER BY Todays_sale DESC
LIMIT  1

-- Q18 Identify revenue trend over time (month-on-month).

SELECT 
    EXTRACT(MONTH FROM o.order_date) AS month_no,
    TRIM(TO_CHAR(o.order_date, 'Month')) AS month_name,
    ROUND(SUM(oi.item_total)::NUMERIC, 2) AS monthly_revenue,
    ROUND(
        (SUM(oi.item_total) :: NUMERIC / (SELECT SUM(item_total) FROM order_items))::NUMERIC * 100,
        2
    ) AS revenue_percentage
FROM orders AS o
JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY EXTRACT(MONTH FROM o.order_date), TO_CHAR(o.order_date, 'Month')
ORDER BY month_no;

-- Q19 Calculate monthly average order value.

SELECT DISTINCT
            EXTRACT(MONTH FROM order_date) AS Month_No,
			TO_CHAR(order_date, 'Month') AS Month_name,
			ROUND( SUM(ot.item_total)::NUMERIC / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders AS o
JOIN order_items AS ot
ON o.order_id = ot.order_id
GROUP BY EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'Month')
ORDER BY month_no ASC 

-- Q20 Find average number of orders placed per customer per month.  

SELECT month_no, month_name, ROUND(AVG(order_no) :: NUMERIC ,2 ) AS Avg_per_order
FROM (
	SELECT month_no, month_name,name,  COUNT(order_id) AS order_no
	FROM (
		SELECT DISTINCT
		             EXTRACT(MONTH FROM order_date) AS month_no, 
					 TO_CHAR(order_date, 'Month') AS Month_name,
					 o.order_id, o.customer_id,
					 c.customer_name AS name 
		FROM orders AS o
		JOIN customers AS c
		ON c.customer_id = o.customer_id ) AS x
	GROUP BY month_no, month_name, name
	ORDER BY month_no ASC ) Y 
GROUP BY month_name, month_no
ORDER BY month_no ASC

-- 📦 Order Behavior & Fulfillment

-- Q21 Find how many orders were returned vs delivered.

SELECT order_status, COUNT(order_id) AS total_order,
       ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(order_id) 
	   FROM orders) :: NUMERIC , 2) AS percentage 
FROM orders 
WHERE LOWER(TRIM(order_status)) IN ('returned', 'delivered')
GROUP BY order_status
ORDER BY total_order

-- Q22 Which city had the highest number of cancelled orders?

SELECT c.location AS city,
       COUNT(order_id) AS total_order 
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
GROUP BY city, o.order_status
HAVING  o.order_status = 'Cancelled'
ORDER BY total_order DESC
LIMIT 5

-- Q23 Calculate average quantity per order across all transactions.

SELECT 
    o.payment_method, 
    ROUND(SUM(ot.quantity)::NUMERIC / COUNT(DISTINCT o.order_id), 2) AS avg_quantity_per_order
FROM orders AS o
JOIN order_items AS ot ON o.order_id = ot.order_id
GROUP BY o.payment_method;

-- Q24 Show distribution of order statuses.

SELECT order_status, COUNT(order_id) AS total_order,
       ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(order_id) 
	   FROM orders) :: NUMERIC , 2) AS percentage 
FROM orders 
GROUP BY order_status
ORDER BY total_order

-- Q25 List orders where the discount applied was over 40%.

SELECT * 
FROM (
SELECT ot.order_id , p.product_name , ROUND((ot.discount_applied * 100):: NUMERIC, 2) AS discount_percentage
FROM order_items AS ot
JOIN products AS p
ON p.product_id = ot.product_id ) AS x
WHERE discount_percentage >= 40


-- 📊 Category-Wise Insights

-- Q26 Which category has the most products?

SELECT category, COUNT(product_id) AS total_product
FROM products 
GROUP BY category
ORDER BY total_product DESC


-- Q27 What is the total revenue by product category?

SELECT p.category, ROUND(SUM(ot.item_total):: NUMERIC ,2) AS total_revenue
FROM products AS p
JOIN order_items AS ot
ON p.product_id = ot.product_id 
GROUP BY p.category 
ORDER BY total_revenue DESC

-- Q28 Which product category gets the most reviews?

SELECT p.category, COUNT(r.review_id) AS total_reviews
FROM products AS p
JOIN reviews AS r
ON p.product_id = r.product_id 
GROUP BY p.category
ORDER BY total_reviews DESC

-- Q29 Find the top-rated category based on average review score.

SELECT p.category,
       ROUND(AVG(Rating):: NUMERIC, 2) AS Avg_Rating
FROM products AS p
JOIN reviews AS r
ON p.product_id = r.product_id 
GROUP BY p.category
ORDER BY avg_rating DESC

-- Q30 Which category has the highest sales volume?

SELECT 
    p.category, 
    SUM(oi.quantity) AS total_quantity_sold
FROM products AS p
JOIN order_items AS oi 
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_quantity_sold DESC;

-- 🧠 Advanced Window Function Practice

-- Q31 Rank top 5 customers by total revenue spent. 

SELECT *,
RANK() OVER(ORDER BY Total_revenue_Spent DESC ) AS ranking
FROM (
	SELECT c.customer_id, c.customer_name AS name, ROUND(SUM(ot.item_total):: NUMERIC ,2 ) AS Total_revenue_Spent
	FROM customers AS c
	JOIN orders AS o
	ON c.customer_id = o.customer_id
	JOIN order_items AS ot
	ON o.order_id = ot.order_id 
	GROUP BY name, c.customer_id ) AS X
LIMIT  5


-- Q32 Show cumulative monthly revenue trend.

SELECT *,
SUM(revenue) OVER(ORDER BY month_no) AS cumulative_revenue
FROM (
	SELECT DISTINCT 
		EXTRACT(MONTH FROM order_date) AS month_no,
		TO_CHAR(order_date, 'Month') AS Month_name , 
		ROUND(SUM(ot.item_total):: NUMERIC, 2) AS revenue 
	FROM orders AS o
	JOIN order_items AS ot
	ON o.order_id = ot.order_id 
	GROUP BY Month_no, month_name 
	ORDER BY month_no ASC ) AS x



-- Q33 For each category, show the most sold product (by quantity).

SELECT *
FROM (
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY category ORDER BY total_quantity DESC ) AS ranking
	FROM (
		SELECT p.product_name AS name, p.category, SUM(ot.quantity) AS total_quantity
		FROM products AS p
		JOIN order_items AS ot
		ON p.product_id = ot.product_id 
		GROUP BY name, p.category ) AS x ) AS z
WHERE ranking = 1



-- Q34 Find running total of quantity sold per product.

SELECT *,
SUM(total_quantity) OVER( ORDER BY total_quantity) AS running_total_quantity
FROM (
	SELECT p.product_id, p.product_name, SUM(ot.quantity) AS total_quantity 
	FROM products AS p
	JOIN order_items AS ot
	ON p.product_id = ot.product_id 
	GROUP BY p.product_id, p.product_name ) AS x
	

-- Q35 Calculate percentage contribution of each product to total revenue.

SELECT  p.product_id, 
		p.product_name AS name, 
		   ROUND(SUM(ot.item_total):: NUMERIC ,2) AS total_revenue, 
          ROUND((SUM(ot.item_total) / (SELECT SUM(item_total) FROM order_items) * 1000):: NUMERIC ,2 )  
	   AS revenue_percentage
FROM products AS p
JOIN order_items AS ot
	ON p.product_id = ot.product_id 
GROUP BY p.product_id, name 
ORDER BY total_revenue DESC



-- 📌 Subquery & Nested Logic 

-- Q36 Find the second highest revenue-generating product.

SELECT *
FROM (
	SELECT *, 
		RANK() OVER(ORDER BY total_revenue DESC) AS ranking
	FROM (
			SELECT p.product_id, 
			   p.product_name,p.category, 
			   ROUND(SUM(ot.item_total):: NUMERIC ,2) AS total_revenue 
			FROM products AS p
			JOIN order_items AS ot 
				ON p.product_id = ot.product_id 
			GROUP BY p.product_id, p.product_name, p.category
			ORDER BY total_revenue DESC ) AS z ) AS x
WHERE ranking =  2

-- Q37 Show customers who bought the most expensive product.

SELECT customer_name, product_name, price
FROM (
	SELECT *,
	DENSE_RANK() OVER(ORDER BY price 	DESC) AS Most_expensive_product
	FROM (
		SELECT c.customer_name, p.product_name, p.price
		FROM products AS p
		JOIN reviews AS r
			ON p.product_id = r.product_id
		JOIN customers AS c
			ON c.customer_id = r.customer_id 
		ORDER BY price DESC ) AS x )  AS c
WHERE Most_expensive_product = 1

-- Q38 List products priced above category average.

SELECT *
FROM (
    SELECT product_id,
           product_name,
           category,
           price,
           ROUND(AVG(price) OVER (PARTITION BY category)::NUMERIC, 2) AS avg_category_price
    FROM products
) AS sub
WHERE price > avg_category_price
ORDER BY category, price DESC;

-- Q39 Identify products with below average sales but high ratings.

SELECT *
FROM (
	SELECT *,
	RANK() OVER(ORDER BY avg_rating DESC) AS ranking
	FROM (
		SELECT p.product_name, 
			   ROUND(AVG(ot.item_total):: NUMERIC ,2) AS avg_sale, 
			   ROUND(AVG(r.rating):: NUMERIC ,2 ) AS avg_rating
		FROM order_items AS ot
		JOIN products AS p
			ON p.product_id = ot.product_id 
		JOIN reviews AS r
			ON r.product_id = p.product_id 
		GROUP BY p.product_name ) AS x
	ORDER BY avg_sale ASC ) AS f
WHERE ranking <= 5
LIMIT 1 

-- Q40 Find customers who ordered the same product multiple times.

SELECT customer_name,product_name,  COUNT(product_id) AS No_of_order 
FROM (
	SELECT c.customer_name, p.product_name, ot.product_id 
	FROM customers AS c
	JOIN orders AS o
		ON c.customer_id = o.customer_id
	JOIN order_items AS ot
		ON o.order_id = ot.order_id 
	JOIN products AS p
		ON p.product_id = ot.product_id ) AS x
GROUP BY customer_name, product_name 
HAVING COUNT(product_id) > 1
ORDER BY No_of_order DESC

-- 🔍 Review Sentiment & Quality

-- Q41 Count reviews by rating (1 to 5 stars).

SELECT rating, COUNT(review_id)
FROM reviews 
GROUP BY rating
ORDER BY rating

-- Q42 Find customers who left 5-star reviews more than once.

SELECT * 
FROM (
	SELECT c.customer_name, r.rating, COUNT(c.customer_id)   AS total_review 
	FROM customers AS c
	JOIN reviews AS r
	ON c.customer_id = r.customer_id 
	GROUP BY c.customer_name, r.rating
	HAVING rating = 5 ) AS z
WHERE total_review >= 2
ORDER BY total_review DESC


-- Q43 Average rating per product.

SELECT r.product_id, p.product_name, ROUND(AVG(r.rating)::NUMERIC, 2) AS avg_rating
FROM reviews AS r
JOIN products AS p
ON p.product_id = r.product_id
GROUP BY r.product_id, p.product_name 
ORDER BY avg_rating DESC

-- Q44 List products with >3.5 star average and low sales.

SELECT *,
RANK() OVER(ORDER BY total_revenue) AS 	ranking
FROM (
	SELECT p.product_name, p.category, ROUND(SUM(ot.item_total):: NUMERIC ,2 ) AS total_revenue, 
		   ROUND(AVG(r.rating):: NUMERIC ,2) AS avg_rating
	FROM products AS p
	JOIN order_items AS ot
		ON p.product_id = ot.product_id 
	JOIN reviews AS r
		ON r.product_id = ot.product_id 
	GROUP BY p.product_name, p.category ) AS x
WHERE avg_rating > 3.5 
ORDER BY total_revenue ASC;

-- Q45 Identify products with 0 reviews but high sales.

SELECT product_id, product_name, total_revenue
FROM (
	SELECT p.product_id, p.product_name, SUM(ot.item_total) AS total_revenue, r.rating
	FROM products AS p
	LEFT JOIN order_items AS ot
		ON p.product_id = ot.product_id 
	LEFT JOIN reviews AS r
		ON r.product_id = ot.product_id 
	GROUP BY p.product_id , p.product_name, r.rating
		ORDER BY total_revenue DESC ) AS x
WHERE rating IS NULL 
	
-- 🎯 Combined Joins & Aggregates

-- Q46 Join all tables to build a master view of customer → order → item → product → review.

SELECT 
  c.customer_id, c.customer_name, c.email, c.location, c.signup_date,
  o.order_id, o.order_date, o.order_status, o.payment_method,
  ot.order_item_id, ot.product_id, ot.quantity, ot.discount_applied, ot.price, ot.item_total,
  p.product_name, p.category, p.price AS product_price, p.stock_quantity,
  r.review_id, r.rating, r.review_date, r.review_text
FROM customers AS c
JOIN orders AS o 
ON c.customer_id = o.customer_id 
JOIN order_items AS ot 
ON o.order_id = ot.order_id
JOIN products AS p 
ON p.product_id = ot.product_id 
LEFT JOIN reviews AS r 
ON r.product_id = p.product_id 
AND r.customer_id = c.customer_id
ORDER BY o.order_date DESC;


-- Q47 Create a revenue leaderboard by city.

SELECT 
  c.location AS city,
  ROUND(SUM(oi.item_total)::NUMERIC, 2) AS total_revenue
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY c.location
ORDER BY total_revenue DESC;

-- Q48 Show most popular product per payment method.

SELECT *
FROM (
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY payment_method ORDER BY total_quantity DESC) 
		AS ranking
		    FROM (
			    SELECT p.product_name, p.category, o.payment_method, SUM(ot.quantity) AS total_quantity
			FROM products AS p
		JOIN order_items AS ot
      ON p.product_id = ot.product_id
	JOIN orders AS o
   ON o.order_id = ot.order_id 
  GROUP BY p.product_name, p.category, o.payment_method ) AS x ) AS z
WHERE ranking = 1


-- Q49 Identify average revenue per customer by category.

SELECT 
  c.customer_name,
  p.category,
  ROUND(SUM(ot.item_total)::NUMERIC, 2) AS total_revenue,
  ROUND(AVG(ot.item_total)::NUMERIC, 2) AS avg_order_value
FROM customers AS c
JOIN orders AS o 
	ON c.customer_id = o.customer_id
JOIN order_items AS ot 
	ON o.order_id = ot.order_id
JOIN products AS p 
	ON p.product_id = ot.product_id
GROUP BY c.customer_name, p.category
	ORDER BY p.category, avg_order_value DESC;


-- Q50 Build a product performance score: (avg rating * quantity sold * revenue)


SELECT product_name, ROUND((avg_rating * Quantity_sold * revenue ):: NUMERIC ,2 ) AS product_performance_score
FROM (
	SELECT p.product_name, 
		   SUM( DISTINCT ot.quantity) AS Quantity_sold, 
	 	   ROUND(SUM( DISTINCT ot.item_total):: NUMERIC ,2 ) AS revenue,
		   ROUND(AVG( DISTINCT r.rating):: NUMERIC ,2) AS avg_rating
	FROM products AS p
	JOIN order_items AS ot
		ON p.product_id = ot.product_id 
	JOIN reviews AS r
		ON r.product_id = ot.product_id 
	GROUP BY product_name ) AS x
ORDER BY product_performance_score DESC

