/*
Project: Retail Inventory Analytics
File: BUSINESS_QUESTIONS_SOLUTIONS.sql
Database: MySQL 8.0+

Expected tables (import the CSV files with these exact table names):
  items_and_stock
  sales_by_item_month
  purchases_by_item_month
  ap_open_bills

Important data-grain rules:
  - items_and_stock: one row per item per month.
  - sales_by_item_month: one row per item per sales month.
  - purchases_by_item_month: one row per item per purchase month.
  - ap_open_bills: open/unpaid supplier bills at the November 2026 snapshot.

Do not join monthly inventory, sales, and purchase facts at item level before
aggregating each fact table. Doing so can multiply monthly amounts.

Metric definitions used:
  - Low stock coverage: available-stock weeks of cover are below planned supplier lead time.
  - Late delivery: actual lead time is greater than planned lead time.
  - Purchase price variance (PPV): landed value minus quantity received times standard landed cost.
    Positive PPV means above standard cost; negative PPV means below standard cost.
  - Slow-moving reserve: 50% of stock value for 181-365 days since last sale;
    100% for more than 365 days, following the dataset documentation.
  - AP overdue status uses the supplied Days overdue field from the November 2026 snapshot.
*/

USE RetailInventoryAnalytics;


/* ================================================================
   QUESTION 1
   Which items have low stock coverage or are at risk of stockout?

   Uses the latest inventory month and the last three months of sales.
   Available weeks of cover = Qty available / average weekly units sold.
   Three months are approximated as 13 weeks.
   An item is at replenishment risk when available cover is shorter than
   its planned supplier lead time.
   ================================================================ */

WITH Latest_Period AS (
    SELECT MAX(Period) AS Latest_Period
    FROM items_and_stock
),
Recent_Demand AS (
    SELECT
        s.`Item code`,
        SUM(s.`Units sold`) / 13.0 AS Avg_Weekly_Demand
    FROM items_and_stock s
    CROSS JOIN Latest_Period lp
    WHERE s.Period BETWEEN
        DATE_FORMAT(
            DATE_SUB(
                STR_TO_DATE(CONCAT(lp.Latest_Period, '-01'), '%Y-%m-%d'),
                INTERVAL 2 MONTH
            ),
            '%Y-%m'
        )
        AND lp.Latest_Period
    GROUP BY s.`Item code`
),
Current_Inventory AS (
    SELECT
        i.`Item code`,
        i.Description,
        i.Category,
        i.Supplier,
        i.Period,
        i.`Qty on hand`,
        i.`Qty allocated to orders`,
        i.`Qty available`,
        i.`Weeks of cover` AS Source_Weeks_of_Cover,
        i.`Lead time planned days`,
        i.`Lost sales units (stockout)`,
        i.`Stocked out (Y/N)`,
        d.Avg_Weekly_Demand
    FROM items_and_stock i
    JOIN Latest_Period lp
        ON i.Period = lp.Latest_Period
    LEFT JOIN Recent_Demand d
        ON i.`Item code` = d.`Item code`
),
Coverage_Calculation AS (
    SELECT
        *,
        `Qty available` / NULLIF(Avg_Weekly_Demand, 0) AS Available_Weeks_Cover,
        `Lead time planned days` / 7.0 AS Planned_Lead_Time_Weeks
    FROM Current_Inventory
),
Risk_Classification AS (
    SELECT
        *,
        CASE
            WHEN `Qty available` <= 0
                THEN 'No available stock at month end'
            WHEN `Lost sales units (stockout)` > 0
                THEN 'Stockout demand recorded during latest month'
            WHEN Avg_Weekly_Demand IS NULL OR Avg_Weekly_Demand = 0
                THEN 'No recent demand - review separately'
            WHEN Available_Weeks_Cover < Planned_Lead_Time_Weeks
                THEN 'At risk - available cover below planned lead time'
            ELSE 'Coverage meets planned lead time'
        END AS Risk_Status
    FROM Coverage_Calculation
)
SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    Period,
    `Qty on hand`,
    `Qty allocated to orders`,
    `Qty available`,
    ROUND(Source_Weeks_of_Cover, 2) AS Source_Weeks_of_Cover,
    ROUND(Available_Weeks_Cover, 2) AS Available_Weeks_Cover,
    `Lead time planned days`,
    `Lost sales units (stockout)`,
    `Stocked out (Y/N)`,
    Risk_Status
FROM Risk_Classification
WHERE Risk_Status <> 'Coverage meets planned lead time'
ORDER BY
    CASE
        WHEN Risk_Status = 'No available stock at month end' THEN 1
        WHEN Risk_Status = 'Stockout demand recorded during latest month' THEN 2
        WHEN Risk_Status = 'At risk - available cover below planned lead time' THEN 3
        ELSE 4
    END,
    Available_Weeks_Cover;


/* ================================================================
   QUESTION 2A
   Which product categories generate the most sales and revenue?
   Full available history: December 2021 to November 2026.
   ================================================================ */

WITH Category_Sales AS (
    SELECT
        Category,
        SUM(`Units sold`) AS Total_Units_Sold,
        SUM(Revenue) AS Total_Revenue,
        SUM(`Cost of goods sold`) AS Total_COGS
    FROM sales_by_item_month
    GROUP BY Category
),
Grand_Total AS (
    SELECT SUM(Total_Revenue) AS All_Category_Revenue
    FROM Category_Sales
)
SELECT
    c.Category,
    c.Total_Units_Sold,
    ROUND(c.Total_Revenue, 2) AS Total_Revenue,
    ROUND(c.Total_COGS, 2) AS Total_COGS,
    ROUND(c.Total_Revenue - c.Total_COGS, 2) AS Gross_Profit,
    ROUND(
        100.0 * c.Total_Revenue / NULLIF(g.All_Category_Revenue, 0),
        2
    ) AS Revenue_Share_Pct
FROM Category_Sales c
CROSS JOIN Grand_Total g
ORDER BY c.Total_Revenue DESC;


/* ================================================================
   QUESTION 2B
   Which individual products generate the most revenue?
   ================================================================ */

WITH Product_Sales AS (
    SELECT
        `Item code`,
        Description,
        Category,
        SUM(`Units sold`) AS Total_Units_Sold,
        SUM(Revenue) AS Total_Revenue,
        SUM(`Cost of goods sold`) AS Total_COGS
    FROM sales_by_item_month
    GROUP BY
        `Item code`,
        Description,
        Category
),
Ranked_Products AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank
    FROM Product_Sales
)
SELECT
    Revenue_Rank,
    `Item code`,
    Description,
    Category,
    Total_Units_Sold,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND(Total_Revenue - Total_COGS, 2) AS Gross_Profit
FROM Ranked_Products
WHERE Revenue_Rank <= 10
ORDER BY Revenue_Rank, `Item code`;


/* ================================================================
   QUESTION 3A
   Where are lost sales occurring by product?
   Lost sales units are the units requested while the shelf was empty.
   ================================================================ */

SELECT
    `Item code`,
    Description,
    Category,
    SUM(`Lost sales units (stockout)`) AS Total_Lost_Sales_Units,
    SUM(
        CASE
            WHEN `Lost sales units (stockout)` > 0 THEN 1
            ELSE 0
        END
    ) AS Months_With_Lost_Sales
FROM items_and_stock
GROUP BY
    `Item code`,
    Description,
    Category
HAVING SUM(`Lost sales units (stockout)`) > 0
ORDER BY Total_Lost_Sales_Units DESC
LIMIT 15;


/* ================================================================
   QUESTION 3B
   Which categories have the highest lost sales?
   ================================================================ */

SELECT
    Category,
    SUM(`Lost sales units (stockout)`) AS Total_Lost_Sales_Units,
    COUNT(
        DISTINCT CASE
            WHEN `Lost sales units (stockout)` > 0 THEN `Item code`
        END
    ) AS Products_Affected
FROM items_and_stock
GROUP BY Category
ORDER BY Total_Lost_Sales_Units DESC;


/* ================================================================
   QUESTION 3C
   In which months were lost sales highest?
   ================================================================ */

SELECT
    Period,
    SUM(`Lost sales units (stockout)`) AS Total_Lost_Sales_Units,
    COUNT(
        DISTINCT CASE
            WHEN `Lost sales units (stockout)` > 0 THEN `Item code`
        END
    ) AS Products_With_Stockout
FROM items_and_stock
GROUP BY Period
HAVING SUM(`Lost sales units (stockout)`) > 0
ORDER BY Period;


/* ================================================================
   QUESTION 4
   How reliable are supplier lead times?

   Actual lead time is NULL in months with no delivery. Excluding NULL
   actual lead times ensures the denominator represents delivery records.
   ================================================================ */

WITH Lead_Time_Detail AS (
    SELECT
        Supplier,
        `Lead time planned days` AS Planned_Lead_Time_Days,
        `Lead time actual days` AS Actual_Lead_Time_Days,
        `Lead time actual days` - `Lead time planned days` AS Delay_Days
    FROM items_and_stock
    WHERE `Lead time actual days` IS NOT NULL
      AND Supplier IS NOT NULL
)
SELECT
    Supplier,
    COUNT(*) AS Delivery_Records,
    SUM(CASE WHEN Delay_Days > 0 THEN 1 ELSE 0 END) AS Late_Deliveries,
    SUM(CASE WHEN Delay_Days <= 0 THEN 1 ELSE 0 END) AS On_Time_Or_Early_Deliveries,
    ROUND(
        100.0 * SUM(CASE WHEN Delay_Days > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS Late_Delivery_Pct,
    ROUND(AVG(Planned_Lead_Time_Days), 2) AS Avg_Planned_Lead_Time_Days,
    ROUND(AVG(Actual_Lead_Time_Days), 2) AS Avg_Actual_Lead_Time_Days,
    ROUND(AVG(Delay_Days), 2) AS Avg_Delay_Days,
    MAX(Delay_Days) AS Maximum_Delay_Days
FROM Lead_Time_Detail
GROUP BY Supplier
ORDER BY Late_Delivery_Pct DESC;


/* ================================================================
   QUESTION 5A
   Are purchasing costs above or below standard cost by supplier?

   Positive PPV = paid more than standard cost.
   Negative PPV = paid less than standard cost.
   ================================================================ */

SELECT
    Supplier,
    SUM(`Qty received`) AS Total_Units_Received,
    ROUND(SUM(`Landed value`), 2) AS Actual_Landed_Spend,
    ROUND(
        SUM(`Qty received` * `Standard cost (landed)`),
        2
    ) AS Standard_Cost_Benchmark,
    ROUND(SUM(`Purchase price variance`), 2) AS Net_Purchase_Price_Variance,
    ROUND(
        100.0 * SUM(`Purchase price variance`)
        / NULLIF(
            SUM(`Qty received` * `Standard cost (landed)`),
            0
        ),
        2
    ) AS PPV_Pct_Of_Standard,
    CASE
        WHEN SUM(`Purchase price variance`) > 0
            THEN 'Above standard cost'
        WHEN SUM(`Purchase price variance`) < 0
            THEN 'Below standard cost'
        ELSE 'At standard cost'
    END AS Cost_Status
FROM purchases_by_item_month
GROUP BY Supplier
ORDER BY Net_Purchase_Price_Variance DESC;


/* ================================================================
   QUESTION 5B
   Which items have the largest positive and negative purchase variances?
   ================================================================ */

SELECT
    `Item code`,
    Description,
    Supplier,
    SUM(`Qty received`) AS Total_Units_Received,
    ROUND(SUM(`Purchase price variance`), 2) AS Net_PPV
FROM purchases_by_item_month
GROUP BY
    `Item code`,
    Description,
    Supplier
ORDER BY Net_PPV DESC
LIMIT 10;

-- To inspect the largest savings / below-standard purchases, reverse the sort.
SELECT
    `Item code`,
    Description,
    Supplier,
    SUM(`Qty received`) AS Total_Units_Received,
    ROUND(SUM(`Purchase price variance`), 2) AS Net_PPV
FROM purchases_by_item_month
GROUP BY
    `Item code`,
    Description,
    Supplier
ORDER BY Net_PPV ASC
LIMIT 10;


/* ================================================================
   QUESTION 6A
   Which items are slow-moving and may require an inventory reserve?

   The source documentation defines:
     181-365 days since last sale: reserve 50% of stock value.
     More than 365 days: reserve 100% of stock value.

   Use only the latest inventory snapshot, not all 60 historical months.
   ================================================================ */

WITH Latest_Period AS (
    SELECT MAX(Period) AS Latest_Period
    FROM items_and_stock
),
Reserve_Calculation AS (
    SELECT
        i.`Item code`,
        i.Description,
        i.Category,
        i.Supplier,
        i.Warehouse,
        i.Period,
        i.`Qty on hand`,
        i.`Days since last sale (month end)` AS Days_Since_Last_Sale,
        i.`Stock value`,
        CASE
            WHEN i.`Days since last sale (month end)` > 365 THEN 1.00
            WHEN i.`Days since last sale (month end)` BETWEEN 181 AND 365 THEN 0.50
            ELSE 0.00
        END AS Reserve_Rate
    FROM items_and_stock i
    JOIN Latest_Period lp
        ON i.Period = lp.Latest_Period
)
SELECT
    `Item code`,
    Description,
    Category,
    Supplier,
    Warehouse,
    Period,
    `Qty on hand`,
    Days_Since_Last_Sale,
    ROUND(`Stock value`, 2) AS Stock_Value,
    ROUND(Reserve_Rate * 100, 0) AS Reserve_Pct,
    ROUND(`Stock value` * Reserve_Rate, 2) AS Estimated_Inventory_Reserve
FROM Reserve_Calculation
WHERE Reserve_Rate > 0
ORDER BY Estimated_Inventory_Reserve DESC;


/* ================================================================
   QUESTION 6B
   What is the total potential slow-moving inventory reserve?
   ================================================================ */

WITH Latest_Period AS (
    SELECT MAX(Period) AS Latest_Period
    FROM items_and_stock
),
Reserve_Calculation AS (
    SELECT
        i.`Item code`,
        i.`Stock value`,
        CASE
            WHEN i.`Days since last sale (month end)` > 365 THEN 1.00
            WHEN i.`Days since last sale (month end)` BETWEEN 181 AND 365 THEN 0.50
            ELSE 0.00
        END AS Reserve_Rate
    FROM items_and_stock i
    JOIN Latest_Period lp
        ON i.Period = lp.Latest_Period
)
SELECT
    COUNT(
        CASE WHEN Reserve_Rate > 0 THEN 1 END
    ) AS Reserve_Eligible_Items,
    ROUND(
        SUM(CASE WHEN Reserve_Rate > 0 THEN `Stock value` ELSE 0 END),
        2
    ) AS Stock_Value_Exposed,
    ROUND(
        SUM(`Stock value` * Reserve_Rate),
        2
    ) AS Estimated_Inventory_Reserve
FROM Reserve_Calculation;


/* ================================================================
   QUESTION 7A
   What supplier bills remain unpaid, and which are overdue?

   The AP file contains open/unpaid supplier bills at the November 2026
   snapshot. Use its Days overdue field rather than CURDATE(), which
   would change the result when the project is run in a later month.
   ================================================================ */

SELECT
    COUNT(*) AS Total_Unpaid_Bills,
    ROUND(SUM(Amount), 2) AS Total_Open_Accounts_Payable,
    SUM(CASE WHEN `Days overdue` > 0 THEN 1 ELSE 0 END) AS Overdue_Bill_Count,
    ROUND(
        SUM(CASE WHEN `Days overdue` > 0 THEN Amount ELSE 0 END),
        2
    ) AS Overdue_Amount,
    SUM(CASE WHEN `Days overdue` = 0 THEN 1 ELSE 0 END) AS Not_Yet_Overdue_Bill_Count,
    ROUND(
        SUM(CASE WHEN `Days overdue` = 0 THEN Amount ELSE 0 END),
        2
    ) AS Not_Yet_Overdue_Amount
FROM ap_open_bills;


/* ================================================================
   QUESTION 7B
   Which suppliers have the largest unpaid and overdue balances?
   ================================================================ */

SELECT
    Supplier,
    COUNT(*) AS Open_Bill_Count,
    ROUND(SUM(Amount), 2) AS Total_Open_Balance,
    SUM(CASE WHEN `Days overdue` > 0 THEN 1 ELSE 0 END) AS Overdue_Bill_Count,
    ROUND(
        SUM(CASE WHEN `Days overdue` > 0 THEN Amount ELSE 0 END),
        2
    ) AS Overdue_Balance,
    ROUND(
        SUM(CASE WHEN `Days overdue` = 0 THEN Amount ELSE 0 END),
        2
    ) AS Not_Yet_Overdue_Balance
FROM ap_open_bills
GROUP BY Supplier
ORDER BY Overdue_Balance DESC, Total_Open_Balance DESC;


/* ================================================================
   QUESTION 7C
   List the specific overdue bills for follow-up.
   ================================================================ */

SELECT
    `Bill number`,
    Supplier,
    `Bill date`,
    `Due date`,
    `Days outstanding`,
    `Days overdue`,
    Amount,
    `Planned payment date`
FROM ap_open_bills
WHERE `Days overdue` > 0
ORDER BY `Days overdue` DESC, Amount DESC;


/* End of business-question solutions. */
