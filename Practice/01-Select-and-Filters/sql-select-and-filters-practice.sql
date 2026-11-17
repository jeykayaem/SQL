-- You're a junior data analyst at a growing food delivery startup. 
-- The company wants to understand customer behavior, product popularity, 
-- and order performance.


-- 1. Retrieve all customer names and their email addresses.
SELECT full_name AS customer_names,email FROM customers;
-- 2. Get a list of products with aliases: product_name as Item and price as Cost.
SELECT product_name AS Item,price AS Cost FROM products;
-- 3. Find all products in the 'Beverages' category.
SELECT * FROM products WHERE category = 'Beverages';
-- 4. Show all products that cost more than $5.
SELECT * FROM products WHERE price > 5;
-- 5. Retrieve all orders with total amount greater than or equal to $10.
SELECT * FROM orders WHERE total_amount >= 10;
-- 6. Are there any customers without phone numbers?
SELECT * FROM customers WHERE phone IS NULL;
-- 7. Find all products priced between $3 and $6.
SELECT * FROM products WHERE price BETWEEN 3 AND 6;

-- 8. Find products named 'French Fries', 'Veg Burger', or 'Margherita Pizza'.
SELECT * FROM products WHERE product_name in ('French Fries', 'Veg Burger','Margherita Pizza');

-- 9. Find customers whose name starts with ‘A’.
SELECT * FROM customers WHERE full_name LIKE 'A%';
SELECT * FROM customers WHERE full_name LIKE '%A'; -- ends with a
SELECT * FROM customers WHERE full_name LIKE '_a%';-- 2nd word with a

-- 10. List all customers who have placed at least one order.
select * from customers
where customer_id in (select customer_id from orders);


-- 11. Find all orders that are not in 'Delivered' status.
SELECT * FROM orders WHERE status != 'Delivered';

-- 12. Show products that are not priced between $4 and $6
select * from products where price not between 4 and 6;
-- 13. List products not in 'Main Course', 'Snacks', or 'Beverages' categories.
select * from products 
where category not in('Main Course', 'Snacks','Beverages');

-- 14. Find customers whose names don’t start with ‘S
SELECT * FROM customers WHERE full_name not LIKE 's%';

-- 15. Find 'total_price' for each order item
SELECT order_id, product_id, quantity, unit_price, (quantity * unit_price) AS total_price
FROM order_items;
-- 16. List the top 10 most expensive products, sorted descending by price.
select * from products
order by price desc
limit 10;
-- 17. Show customers sorted alphabetically by name.
select * from customers
order by full_name asc;

-- 18. Show the 5 most recent customers based on 'created_at'.
SELECT * FROM customers ORDER BY created_at DESC LIMIT 5;

-- 19. Display any 3 random products.
select * from products
order by rand();