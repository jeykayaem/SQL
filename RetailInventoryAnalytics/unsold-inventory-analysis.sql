-- Which suppliers have the highest value of inventory that has not sold in the latest sales month?

WITH Latest_Inventory AS (
    SELECT *
    FROM items_and_stock
    WHERE Period = (
        SELECT MAX(Period)
        FROM items_and_stock
    )
),

Latest_Sales AS (
    SELECT DISTINCT
        `Item code`
    FROM sales_by_item_month
    WHERE `Month` = (
        SELECT MAX(`Month`)
        FROM sales_by_item_month
    )
)

SELECT
    i.Supplier,
    ROUND(
        SUM(
            i.`Qty available` *
            i.`Average cost (stock value / qty)`
        ), 2
    ) AS available_inventory_value
FROM Latest_Inventory i
LEFT JOIN Latest_Sales s
    ON i.`Item code` = s.`Item code`
WHERE i.`Qty available` > 0
  AND s.`Item code` IS NULL
GROUP BY i.Supplier
ORDER BY available_inventory_value DESC;
