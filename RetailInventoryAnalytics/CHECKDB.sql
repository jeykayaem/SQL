select * from ap_open_bills;
select * from items_and_stock;
select * from purchases_by_item_month;
select * from  sales_by_item_month;

SELECT COUNT(*) AS total_inventory_records
FROM items_and_stock;

SELECT COUNT(*) AS total_sales_records
FROM sales_by_item_month;

SELECT COUNT(*) AS total_purchase_records
FROM purchases_by_item_month;

SELECT COUNT(*) AS total_open_bills
FROM ap_open_bills;