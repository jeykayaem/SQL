
-- 1. Retrieve a list of all distinct product categories.
select distinct category FROM products;

-- 2. Show all product names in uppercase.
SELECT upper(product_name) FROM products;

-- 3. Select all customers who have not provided a phone number.
SELECT * FROM customers WHERE phone IS NULL;
-- 4. Show the first 5 customers sorted alphabetically by name.
SELECT * FROM customers order by full_name LIMIT 5;

-- 5. Show the 6th to 10th customers alphabetically.
SELECT * FROM customers order by full_name LIMIT 5
OFFSET 5;

-- 6. Show products with a price between $5 and $15.
SELECT * FROM PRODUCTS WHERE price BETWEEN 5 AND 15;
-- 7. List orders and label them as "High" if total_amount > $50, "Medium" if between $20-$50, and "Low" otherwise.
SELECT order_id, total_amount,
  CASE 
    WHEN total_amount > 50 THEN 'High'
    WHEN total_amount BETWEEN 20 AND 50 THEN 'Medium'
    ELSE 'Low'
  END AS priority
FROM orders;
-- 8. Display orders with total_amount NULL, and replace it with 0.
 SELECT order_id, COALESCE(total_amount, 0) AS total_amount FROM orders;


-- 9. Show full_name and the first word from their name only.
SELECT full_name,SUBSTRING_INDEX(full_name, ' ', 1) AS first_name FROM customers;
-- 10. Show all orders placed today (assume CURRENT_DATE).
SELECT * FROM orders WHERE order_date = CURRENT_DATE;

-- 11. List orders sorted by priority: Delivered > Confirmed > Shipped > Pending.
SELECT * FROM orders
ORDER BY 
  CASE 
    WHEN status = 'Delivered' THEN 1
    WHEN status = 'Confirmed' THEN 2
    WHEN status = 'Shipped' THEN 3
    ELSE 4
  END;
  
-- 12. Show current date, and how many days ago each order was placed.
SELECT order_id, 
order_date, 
CURRENT_DATE AS today, 
datediff(CURRENT_DATE, order_date) AS days_ago 
from orders;

-- 13. Show a list of customers with NULL phone numbers labeled as 'Missing'.
SELECT full_name, COALESCE(phone, 'Missing') AS phone FROM customers;

-- 14. List products whose name contains the word 'Pizza'.
SELECT * FROM products
WHERE product_name LIKE '%Pizza%';

-- 15. Display total number of characters in each product name.
SELECT product_name, LENGTH(product_name) AS name_length FROM products;