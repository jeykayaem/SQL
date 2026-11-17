-- Which suppliers have the highest value of inventory that has not sold in the latest sales month?

SELECT DISTINCT
   s.Category,
	round(sum(s.`Qty available`*s.`Average cost (stock value / qty)`),2) as  Inventoryvalue
FROM items_and_stock s
LEFT JOIN (
    SELECT DISTINCT `Item code`
	FROM sales_by_item_month
	WHERE Month = (
    SELECT MAX(Month)
    FROM sales_by_item_month
)
) p
    ON s.`Item code` = p.`Item code`
    WHERE s.Period = (
    SELECT MAX(Period)
    FROM items_and_stock
)
AND s.`Qty available` > 0
AND p.`Item code` IS NULL
GROUP BY s.Category
ORDER BY Inventoryvalue DESC;


