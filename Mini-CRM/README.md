# Mini CRM — SQL & PostgreSQL Basics

A beginner-friendly SQL project that demonstrates how to build and work with a simple **Customer Relationship Management (CRM)** database using **PostgreSQL**.

The project is designed around a small food-delivery startup that wants to manage:

- Customers
- Food products
- Orders
- Order items
- Pricing
- Order status
- Basic data updates and deletes

The main goal is to practice core **DDL (Data Definition Language)** and **DML (Data Manipulation Language)** concepts using a realistic relational database structure.

---

## Project Overview

The database is named:

```sql
mini_crm
```

It contains four main tables:

```text
customers
   |
   | customer_id
   v
orders
   |
   | order_id
   v
order_items
   |
   | product_id
   v
products
```

### Relationship Summary

- One customer can have many orders.
- One order can contain many order items.
- One product can appear in many order items.
- `order_items` connects orders and products.

---

## Database Schema

### 1. `customers`

Stores customer information.

| Column | Data Type | Constraint |
|---|---|---|
| `customer_id` | `SERIAL` | Primary Key |
| `full_name` | `VARCHAR(100)` | Not Null |
| `email` | `VARCHAR(100)` | Unique, Not Null |
| `phone` | `VARCHAR(15)` | Optional |
| `created_at` | `TIMESTAMP` | Default Current Timestamp |

```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 2. `products`

Stores food-menu items.

| Column | Data Type | Constraint |
|---|---|---|
| `product_id` | `SERIAL` | Primary Key |
| `product_name` | `VARCHAR(100)` | Not Null |
| `category` | `VARCHAR(50)` | Optional |
| `price` | `NUMERIC(10,2)` | Not Null |
| `is_active` | `BOOLEAN` | Default `TRUE` |

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);
```

---

### 3. `orders`

Stores customer orders.

| Column | Data Type | Constraint |
|---|---|---|
| `order_id` | `SERIAL` | Primary Key |
| `customer_id` | `INT` | Foreign Key |
| `order_date` | `TIMESTAMP` | Default Current Timestamp |
| `total_amount` | `NUMERIC(10,2)` | Optional |
| `status` | `VARCHAR(20)` | Default `Pending` |

```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10,2),
    status VARCHAR(20) DEFAULT 'Pending'
);
```

---

### 4. `order_items`

Stores the individual products included in each order.

| Column | Data Type | Constraint |
|---|---|---|
| `order_item_id` | `SERIAL` | Primary Key |
| `order_id` | `INT` | Foreign Key |
| `product_id` | `INT` | Foreign Key |
| `quantity` | `INT` | Check `quantity > 0` |
| `unit_price` | `NUMERIC(10,2)` | Not Null |

```sql
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL
);
```

---

## SQL Concepts Covered

### DDL — Data Definition Language

Used to define or change database structure.

Commands demonstrated:

```sql
CREATE DATABASE
CREATE TABLE
DROP TABLE
TRUNCATE TABLE
```

Examples:

```sql
CREATE DATABASE mini_crm;

TRUNCATE TABLE order_items;

DROP TABLE products;
```

---

### DML — Data Manipulation Language

Used to add, modify, and delete data.

Commands demonstrated:

```sql
INSERT
UPDATE
DELETE
```

Example:

```sql
UPDATE products
SET price = 179.99
WHERE product_id = 2;
```

Example:

```sql
DELETE FROM customers
WHERE customer_id = 2;
```

---

### DQL — Data Query Language

Used to retrieve data.

```sql
SELECT *
FROM customers;
```

The project also contains a basic `JOIN` query:

```sql
SELECT
    c.full_name,
    o.order_id,
    o.total_amount,
    o.status,
    o.order_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;
```

---

## Constraints Used

The project demonstrates several important SQL constraints.

### Primary Key

Uniquely identifies each row.

```sql
customer_id SERIAL PRIMARY KEY
```

### Foreign Key

Creates a relationship between tables.

```sql
customer_id INT REFERENCES customers(customer_id)
```

### NOT NULL

Requires a value.

```sql
full_name VARCHAR(100) NOT NULL
```

### UNIQUE

Prevents duplicate values.

```sql
email VARCHAR(100) UNIQUE NOT NULL
```

### DEFAULT

Automatically provides a value when one is not supplied.

```sql
status VARCHAR(20) DEFAULT 'Pending'
```

### CHECK

Restricts values based on a condition.

```sql
quantity INT CHECK (quantity > 0)
```

---

## Sample Data

The script contains sample data for:

- 15 customers
- 30 food products
- Multiple orders
- Multiple order items

Example customer:

```sql
('Aditi Sharma', 'aditi@example.com', '9876543210')
```

Example product:

```sql
('Margherita Pizza', 'Main Course', 499.99)
```

Example order:

```sql
(1, 699.98, 'Confirmed')
```

---

## How to Run the Project

### Prerequisites

Install:

- PostgreSQL
- pgAdmin, DBeaver, DataGrip, TablePlus, or another PostgreSQL client

---

### Step 1 — Create the Database

Run:

```sql
CREATE DATABASE mini_crm;
```

---

### Step 2 — Connect to the Database

Connect to:

```text
mini_crm
```

If using `psql`:

```sql
\c mini_crm
```

---

### Step 3 — Create the Tables

Run the table-creation statements in this order:

```text
1. customers
2. products
3. orders
4. order_items
```

The order matters because `orders` depends on `customers`, while `order_items` depends on both `orders` and `products`.

---

### Step 4 — Insert Sample Data

Insert the sample records in this order:

```text
1. customers
2. products
3. orders
4. order_items
```

---

### Step 5 — Verify the Data

```sql
SELECT *
FROM customers;

SELECT *
FROM products;

SELECT *
FROM orders;

SELECT *
FROM order_items;
```

---

## Important Execution Notes

The SQL file includes the following practice commands near the beginning:

```sql
TRUNCATE TABLE order_items;
DROP TABLE products;
```

If the entire file is executed from top to bottom, `DROP TABLE products` removes the `products` table before the later product inserts are executed.

For normal setup, keep these commands commented out and run them separately only when practicing `TRUNCATE` and `DROP`.

```sql
-- TRUNCATE TABLE order_items;
-- DROP TABLE products;
```

---

## Data Notes

### Customer IDs

The current customer insert section contains 15 customers, while some order records reference customer IDs greater than 15.

Because `orders.customer_id` is a foreign key referencing `customers.customer_id`, those inserts require corresponding customer records to exist.

Before running the full order dataset, either:

- Add additional customers for the referenced IDs, or
- Change those order records to use valid existing customer IDs.

---

### Product Pricing

The sample product data contains two noticeably different price ranges.

For example:

```text
Margherita Pizza    499.99
Veg Burger          199.99
Paneer Tikka          4.99
Garlic Bread          2.49
```

If the dataset is intended to use one currency and one pricing scale, the values should be standardized before performing revenue analysis.

---

## Example Practice Queries

### Find all customers

```sql
SELECT *
FROM customers;
```

### Find all active products

```sql
SELECT *
FROM products
WHERE is_active = TRUE;
```

### Find pending orders

```sql
SELECT *
FROM orders
WHERE status = 'Pending';
```

### Find orders with customer names

```sql
SELECT
    c.full_name,
    o.order_id,
    o.total_amount,
    o.status
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;
```

### Find all items in an order

```sql
SELECT
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.order_id = 1;
```

### Calculate an order-item total

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id;
```

---

## Suggested Learning Path

This project can be extended step by step:

```text
DDL & DML
   ↓
SELECT & WHERE
   ↓
ORDER BY & LIMIT
   ↓
DISTINCT
   ↓
LIKE / IN / BETWEEN
   ↓
COUNT / SUM / AVG
   ↓
GROUP BY
   ↓
HAVING
   ↓
INNER JOIN
   ↓
LEFT JOIN
   ↓
Subqueries
   ↓
CASE
   ↓
CTEs
   ↓
Window Functions
```

---

## Future Improvements

Possible extensions to the project:

- Add customer addresses
- Add payment methods
- Add delivery addresses
- Add restaurant information
- Add product inventory
- Add discounts and coupons
- Add delivery status
- Add payment status
- Add order cancellation reasons
- Add audit/history tables
- Add indexes
- Add views
- Add stored procedures
- Add triggers
- Build reporting queries

---

## Business Questions You Can Solve Later

Once the database is complete, it can be used to answer questions such as:

- Which customers placed the most orders?
- Which customers spent the most money?
- Which products sell the most?
- Which products have never been ordered?
- What is the average order value?
- What is the total revenue?
- Which order status occurs most frequently?
- How much revenue comes from each product category?
- Which customers have not placed an order?
- What are the top 5 products by sales?
- How many orders were placed each month?
- Which products generate the highest revenue?

---

## Project File

Main SQL script:

```text
DDL_DML.sql
```

---

## Purpose

This project is intended for beginners learning:

- SQL fundamentals
- PostgreSQL basics
- Relational database design
- Primary and foreign keys
- Constraints
- DDL
- DML
- Basic joins
- Basic CRUD operations

It can also serve as a foundation for later **Data Analyst**, **SQL interview**, and **database practice** exercises.

---

## License

This project is for learning and practice purposes.