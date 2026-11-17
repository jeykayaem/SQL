-- Aggregate Function Questions
-- Only use GROUP BY, COUNT, SUM, AVG, MIN, MAX
-- Tables: orders, products, order_items

-- Q1. Find the total number of orders for each status.
select status as order_status,count(*) as order_count 
from orders
group by  status
order by 2 desc;
-- Q2. What is the average order value for each order status?
select status,round(avg(total_amount),2) as Avg_amount 
from orders
group by  status
order by 2 desc;

-- Q3. Find the total revenue generated on each order date.
select order_date,sum(total_amount) AS total_revenue
from orders
group by order_date;

-- Q4. What is the highest, lowest, and average order amount across all orders?
select 
max(total_amount) AS max_order,
min(total_amount) AS min_order,
avg(total_amount) AS avg_order 
from orders;

-- Q5. How many products are available in each category?
SELECT count(product_name) AS no_of_product,
category 
FROM products
group by category
order by 1;
-- Q6. What is the average price of products in each category?
SELECT category,
avg(price) AS avg_price 
FROM products
group by category
order by 1;

-- Q7. Find the highest and lowest price among all products.
select max(price) AS highest_price,
min(price) AS lowest_price
from products;

-- Q8. How many units of each product_id were sold (based on order_items)?
SELECT product_id, SUM(quantity) AS total_quantity
FROM order_items
GROUP BY product_id;

-- Q9. What is the average unit price for each product_id in order_items?
select product_id,
avg(unit_price) as avg_price 
from order_items
group by product_id
order by 1;
-- Q10. How many times was each product_id ordered (count of appearances in order_items)?
SELECT product_id, COUNT(*) AS times_ordered
FROM order_items
GROUP BY product_id;