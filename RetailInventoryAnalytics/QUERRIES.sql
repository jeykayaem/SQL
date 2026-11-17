-- Q1 – Inspect inventory records
select * from items_and_stock
limit 10;
-- Q2 – Identify unique products
select distinct(Description) from purchases_by_item_month

SELECT DISTINCT `Item code`, Description
FROM purchases_by_item_month
ORDER BY `Item code`;

-- Q3 – Identify product categories
select distinct Category from items_and_stock;

-- Q4 – Understand historical coverage
SELECT
    MIN(Period) AS first_period,
    MAX(Period) AS last_period,
    COUNT(DISTINCT Period) AS total_months
FROM items_and_stock;

-- Q5 How many total products are in each category?
SELECT
    Category,
    COUNT(DISTINCT `Item code`) AS total_products
FROM items_and_stock
GROUP BY Category
ORDER BY total_products DESC;

-- Q6Which suppliers supply the most unique products?
SELECT
    Supplier,
    COUNT(DISTINCT `Item code`) AS products
FROM items_and_stock
GROUP BY Supplier
ORDER BY products DESC
;

-- Q7Which warehouses store the most products?
SELECT
    Warehouse,
    COUNT(DISTINCT `Item code`) AS products
FROM items_and_stock
GROUP BY Warehouse
ORDER BY products DESC
limit 1;

-- Q8What is the total inventory value by category?
SELECT
    Category,
    SUM(`Stock value`) AS total_inventory_value
FROM items_and_stock
GROUP BY Category
ORDER BY total_inventory_value DESC;
-- Q9Which 10 products have the highest stock value?
SELECT
    `Item code`,
    Description,
    Category,
    `Stock value`
FROM items_and_stock
ORDER BY `Stock value` DESC
LIMIT 10;

-- Q10How many products are currently stocked out?
SELECT
    COUNT(DISTINCT `Item code`) AS stocked_out_products
FROM items_and_stock
WHERE `Stocked out (Y/N)` = 'Y';
 
 -- Q11How many records have zero available quantity?
SELECT
    COUNT(*) AS zero_available_records
FROM items_and_stock
WHERE `Qty available` = 0;

-- Q12Find the top 5 product categories by total revenue.
SELECT
    Category,
    SUM(Revenue) AS total_revenue
FROM sales_by_item_month
GROUP BY Category
ORDER BY total_revenue DESC
LIMIT 5;

-- Q13Find the top 5 suppliers based on total purchase value.
SELECT
    Supplier,
    round(SUM(`Landed value`),2) AS total_purchase_value
FROM purchases_by_item_month
GROUP BY Supplier
ORDER BY total_purchase_value DESC
LIMIT 5;

-- Q14Find products where actual lead time is greater than planned lead time.
SELECT
    `Item code`,
    Description,
    Supplier,
    `Stock value`,
 `Lead time planned days` AS  Planned_lead_time,
`Lead time actual days` AS Actual_lead_time
 FROM items_and_stock
 WHERE `Lead time actual days` > `Lead time planned days`
 ORDER BY `Lead time actual days` DESC;

-- Q15Find the top 10 products with the highest lost sales units.
SELECT
    `Item code`,
    Description,Category,
    `Lost sales units (stockout)`
 FROM items_and_stock
 ORDER BY `Lost sales units (stockout)` DESC
 LIMIT 10;
 
 -- Q16Find total revenue for each month.
SELECT
    DATE_FORMAT(`Month`, '%Y-%m') AS sales_month,
    SUM(Revenue) AS total_revenue
FROM sales_by_item_month
GROUP BY DATE_FORMAT(`Month`, '%Y-%m')
ORDER BY sales_month;

-- Q17Find products with available stock below 100 and inventory value above 5,000.
SELECT
    `Item code`,
    Description,
    Category,
    SUM(`Stock value`) AS total_inventory_value
FROM items_and_stock
WHERE `Qty available` < 100
GROUP BY
    `Item code`,
    Description,
    Category
HAVING SUM(`Stock value`) > 5000
ORDER BY total_inventory_value DESC;

SELECT
    `Item code`,
    Description,
    Category,
    `Qty available`,
    `Stock value`
FROM items_and_stock
WHERE Period = (
    SELECT MAX(Period)
    FROM items_and_stock
)
AND `Qty available` < 100
AND `Stock value` > 5000
ORDER BY `Stock value` DESC;


/* The inventory manager wants to identify products that 
require immediate attention because they are either stocked out or have no available stock.*/
SELECT
    `Item code`,
    Description,
    Category,
    Warehouse,
    Period,
    `Qty available`,
    `Stocked out (Y/N)`
FROM items_and_stock
WHERE `Qty available` = 0
  AND `Stocked out (Y/N)` = 'Y'
ORDER BY Period, Category;
  -- THERE WAS ISSUE WITH OR AS STOCK GETS UPDATE SO COUNTED  
    SELECT
    `Item code`,
    Description,
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Stocked out (Y/N)`) AS different_stockout_statuses
FROM items_and_stock
GROUP BY
    `Item code`,
    Description
HAVING COUNT(*) > 1
ORDER BY total_records DESC;
SELECT
    `Item code`,
    Description,
    Period,
    `Qty available`,
    `Stocked out (Y/N)`
FROM items_and_stock
WHERE `Item code` = 'IT-10005'
ORDER BY Period;

-- Find products in these three categories:Bearings,Electrical,Fasteners

SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    `Stock value`
FROM items_and_stock
WHERE Category IN ('Bearings', 'Electrical', 'Fasteners')
ORDER BY `Stock value` DESC
LIMIT 20;

-- Find products that do not belong to these categories:Bearings,Electrical,Fasteners
SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    `Stock value`
FROM items_and_stock
WHERE Category NOT IN ('Bearings', 'Electrical', 'Fasteners')
ORDER BY `Stock value` DESC
LIMIT 20;

-- Business scenario: The inventory manager wants to identify products with a stock value between $1,000 and $10,000.
SELECT
    `Item code`,
    Description,
    Category,
    Warehouse,
    `Stock value`
FROM items_and_stock
WHERE `Stock value`BETWEEN 1000 and 10000
ORDER BY `Stock value` DESC
LIMIT 20;


-- The purchasing manager wants to identify all products whose descriptions contain the word bearing.
SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    `Stock value`
FROM items_and_stock
WHERE Description LIKE '%Bearing%'
ORDER BY `Stock value` DESC
LIMIT 20;

-- The inventory manager wants to identify products that have no supplier assigned.
SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    Warehouse
FROM items_and_stock
WHERE Supplier IS NULL
ORDER BY Category;


-- The inventory manager wants a report that displays Unknown Supplier whenever the supplier field is NULL.
SELECT
    `Item code`,
    Description,
    Category,
    COALESCE(Supplier, 'Unknown Supplier') AS Supplier,
    Warehouse
FROM items_and_stock
ORDER BY Category;

-- You can also use it with inventory calculations:
SELECT
    DISTINCT `Item code`,
    COALESCE(`Qty available`, 0) AS available_stock
FROM items_and_stock;

/* The inventory manager wants to classify products based on available stock.

Create a new column called Stock Status:
- Quantity = 0 → Out of Stock
- Quantity below 100 → Low Stock
- Quantity from 100 to 500 → Normal Stock
- Quantity above 500 → High Stock*/
SELECT
    distinct`Item code`,
    Description,
    Category,
    `Qty available`,
    CASE
        WHEN `Qty available` = 0 THEN 'Out of Stock'
        WHEN `Qty available` < 100 THEN 'Low Stock'
        WHEN `Qty available` BETWEEN 100 AND 500 THEN 'Normal Stock'
        WHEN `Qty available` > 500 THEN 'High Stock'
    END AS Stock_Status
FROM items_and_stock
ORDER BY `Qty available` ASC;


-- Q. Identify duplicate item records for the same month
SELECT
    `Item code`,
    Period,
    COUNT(*) AS duplicate_count
FROM items_and_stock
GROUP BY
    `Item code`,
    Period
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
-- Q. Which products have more than 20 weeks of inventory cover?
SELECT
    `Item code`,
    Description,
    Category,
    Period,
    `Weeks of cover`
FROM items_and_stock
WHERE `Weeks of cover` > 20
ORDER BY `Weeks of cover` DESC;

-- Q Find suppliers whose average actual lead time exceeds 30 days
SELECT
    Supplier,
    AVG(`Lead time actual days`) AS avg_actual_lead_time,
    COUNT(*) AS delivery_records
FROM items_and_stock
WHERE `Lead time actual days` IS NOT NULL
  AND Supplier IS NOT NULL
GROUP BY Supplier
HAVING AVG(`Lead time actual days`) > 30
ORDER BY avg_actual_lead_time DESC;

-- Q17Which products have missing supplier information?
SELECT
    `Item code`,
    Description,
    Category,
    Supplier
FROM items_and_stock
WHERE Supplier IS NULL;

-- Q18. Which products have missing actual lead-time values?
SELECT
    `Item code`,
    Description,
    Supplier,
    `Lead time planned days`,
    `Lead time actual days`
FROM items_and_stock
WHERE `Lead time actual days` IS NULL;

-- . Which products have negative stock quantities?
SELECT
    `Item code`,
    Description,
    Warehouse,
    `Qty on hand`
FROM items_and_stock
WHERE `Qty on hand` < 0;
-- Q. Count products with missing selling prices, unit costs or landed costs
SELECT
    COUNT(DISTINCT CASE
        WHEN `Selling price` IS NULL
        THEN `Item code`
    END) AS missing_selling_price,

    COUNT(DISTINCT CASE
        WHEN `Unit cost` IS NULL
        THEN `Item code`
    END) AS missing_unit_cost,

    COUNT(DISTINCT CASE
        WHEN `Landed cost (with freight)` IS NULL
        THEN `Item code`
    END) AS missing_landed_cost

FROM items_and_stock;