-- INNER JOIN Examples

-- 1. Show customer names along with their order IDs. (Hint: Use orders and customers)
select c.full_name,o.order_id
from customers c
inner join orders o
on  c.customer_id=o.customer_id;

-- 2. List the names of products and their prices that have been ordered. (Hint: Use products and order_items)
select p.product_name,p.price
from products p
inner join order_items oi
on  p.product_id=oi.product_id;
-- LEFT JOIN Examples

-- 3. Show each customer's name and the total amount of their order. Include customers even if they haven't placed an order. (Hint: Use customers and orders)
SELECT c.full_name, SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.full_name;

-- 4. Show all products and whether they have been ordered. (Hint: Use LEFT JOIN between products and order_items)
select p.product_name,oi.order_id
from products p
left join order_items oi
on  p.product_id=oi.product_id;
-- FULL OUTER JOIN Examples

-- 5. Show a list of all customers and orders. Include customers with no orders and orders with missing customer information. (Hint: Use FULL OUTER JOIN)
SELECT c.full_name, o.order_id
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- 6. List all products and orders. Include products never ordered and orders with missing products. (Hint: Use FULL OUTER JOIN)
select p.product_name,oi.order_id
from products p
FULL OUTER join order_items oi
on  p.product_id=oi.product_id;
-- SELF JOIN Example

-- 7. Show customers who share the same phone number. (Hint: SELF JOIN on customers table)

-- Remaining Join Practice Questions

-- 8. Show order IDs along with the full name of the customer and the order status. (Hint: Use orders and customers)
SELECT c.full_name, o.order_id,o.status
FROM orders o 
inner JOIN customers c
ON o.customer_id = c.customer_id;

-- 9. List all products ordered in each order. Show order_id and product_name. (Hint: Use order_items and products)
select oi.order_id,p.product_name
from order_items oi
inner join products p
on  oi.product_id=p.product_id;

-- 10. Display all order items with product name, quantity, and unit_price. (Hint: Use order_items and products)
select p.product_name,oi.quantity,oi.unit_price
from order_items oi
inner join products p
on  oi.product_id=p.product_id;
-- 11. Show all customers who have placed an order, along with their email. (Hint: Use DISTINCT if needed)
SELECT c.full_name,c.email
FROM orders o 
inner JOIN customers c
ON o.customer_id = c.customer_id;
-- 12. List all orders that include "Pizza" in the product name. Show order_id and product_name.
select oi.order_id,p.product_name
from order_items oi
inner join products p
on  oi.product_id=p.product_id
where p.product_name like '%pizza';

-- 13. Show all orders with their customer's full name, product name, and quantity. (Hint: Use three tables!)
select o.order_id,c.customer_id,p.product_name,oi.quantity
from orders o
inner join customers c
on  o.customer_id = c.customer_id
inner join order_items oi
ON o.order_id = oi.order_id
inner join products p
on  oi.product_id = p.product_id;

-- 14. Bonus: Show all products that have **never** been ordered. (Hint: LEFT JOIN and IS NULL)
SELECT p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;