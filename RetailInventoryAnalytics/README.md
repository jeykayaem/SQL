# Retail Inventory Analytics

A MySQL portfolio project analysing inventory availability, product demand, lost sales, supplier delivery performance, purchasing cost variance, slow-moving stock, and accounts payable for a fictional industrial distributor.

## Business objective

Use item-level and monthly operational data to help inventory, purchasing, and finance teams identify replenishment risks, understand product and category performance, reduce lost sales, evaluate supplier reliability, control purchasing costs, manage aged stock, and prioritize overdue supplier bills.

All company, supplier, item, and transaction values in this dataset are synthetic. Currency is USD.

## Dataset

**Source:** [Inventory Data Studio — Inventory Optimization Pro](https://inventoryoptimization.pro/inventory-data-studio/)

**Coverage:** December 2021 to November 2026  
**Latest inventory and AP snapshot:** November 2026

| CSV file | Rows | Grain / contents |
|---|---:|---|
| `items_and_stock.csv` | 9,000 | One row per item per month; stock, available quantity, stock value, sales, lost sales, weeks of cover, and supplier lead times |
| `sales_by_item_month.csv` | 8,551 | One row per item per month; units sold, revenue, and cost of goods sold |
| `purchases_by_item_month.csv` | 6,098 | One row per item per month with receipts; received quantity, landed value, standard landed cost, and purchase price variance |
| `ap_open_bills.csv` | 68 | Open/unpaid supplier bills at the November 2026 snapshot, including due dates and days overdue |

### Tables expected in MySQL

Import the four CSVs using these table names and retain the source column names:

- `items_and_stock`
- `sales_by_item_month`
- `purchases_by_item_month`
- `ap_open_bills`

The SQL scripts use the original column headings, including spaces, quoted with MySQL backticks.

## Business questions and findings

The solutions are in [`BUSINESS_QUESTIONS_SOLUTIONS.sql`](BUSINESS_QUESTIONS_SOLUTIONS.sql).

### 1. Low stock coverage and stockout risk

For the latest month, November 2026:

- **12 items** had zero available quantity at month end.
- **35 additional items** had positive available quantity but available stock coverage shorter than their planned supplier lead time.
- **8 items** had no sales in the latest three-month demand window and are flagged for separate slow-moving review, rather than being treated as ordinary replenishment-risk items.

Available weeks of cover is calculated as available quantity divided by average weekly units sold over the latest three months (13 weeks). This is compared with planned supplier lead time expressed in weeks.

### 2. Product and category sales performance

Across the full dataset:

- **8,509,520 units** sold.
- **$268,911,353.49** in revenue.

| Category | Revenue | Revenue share |
|---|---:|---:|
| Fluid power | $68,728,044.46 | 25.56% |
| Bearings | $57,765,967.93 | 21.48% |
| Fasteners | $53,340,724.47 | 19.84% |
| Electrical | $51,006,588.29 | 18.97% |
| Power transmission | $38,070,028.34 | 14.16% |

The highest-revenue item was **IT-10128 — Filter cartridge 10-128**, with **$9,778,863.23** in revenue over the available history.

### 3. Lost sales caused by stockouts

- **199,680 units** of demand were recorded as lost sales due to stockouts across the history.
- **86 distinct items** had at least one lost-sales record.
- Bearings recorded the largest category total: **64,956 lost units**, followed by Electrical (**50,676**) and Fasteners (**42,404**).
- The largest item-level lost-sales total was **IT-10135 — Bolt assortment M-135**, at **21,825 units**.

The queries report lost units by item, category, and month to help target replenishment and investigate recurring stockouts.

### 4. Supplier lead-time reliability

Across **6,098 delivery records** with a non-null actual lead time:

- Average planned lead time: **35.88 days**.
- Average actual lead time: **36.83 days**.
- **1,356 deliveries** were late, or **22.24%**.
- Summit Trading had the highest late-delivery rate among suppliers (**24.05%**); Eastbrook Co had the lowest (**18.47%**).

A delivery is classified as late when actual lead time is greater than planned lead time. Months without a delivery are excluded because actual lead time is blank for those months.

### 5. Purchasing cost versus standard cost

Across the purchasing history:

- Actual landed spend: **$193,311,076.22**.
- Standard-cost benchmark: **$190,089,871.44**.
- Net purchase price variance: **+$3,221,204.78**, approximately **1.69% above** the standard-cost benchmark.

Positive purchase price variance means landed purchase cost was above standard; negative variance means it was below standard. The supplier-level query compares net variance, so an individual supplier may still have some purchase records below standard even when its total variance is positive.

Granite Partners had the largest total positive variance (**$1,822,570.88**) across suppliers.

### 6. Slow-moving inventory and potential reserve

Using the latest inventory snapshot and the dataset's reserve rule:

- **8 items** had gone 181–365 days without a sale.
- No items in the latest snapshot were more than 365 days since their last sale.
- Stock value exposed to the reserve rule: **$1,331,228.26**.
- Estimated reserve at 50%: **$665,614.13**.

The source rule applies a 50% reserve to stock value for items 181–365 days since last sale and a 100% reserve for items over 365 days. This is an estimated reserve based on the supplied dataset rule, not an accounting determination.

### 7. Unpaid and overdue supplier bills

At the November 2026 snapshot:

- **68 unpaid bills** totalled **$6,063,582.76**.
- **5 bills** were overdue, totalling **$468,746.68**.
- The remaining **63 bills** totalled **$5,594,836.08** and were not overdue in the supplied snapshot.

Summit Trading had the largest overdue supplier balance (**$230,339.34** across two overdue bills). The AP queries use the supplied `Days overdue` field so that the result remains tied to the dataset snapshot rather than changing with the date on which the SQL is run.

## SQL files

| File | Purpose |
|---|---|
| `DATABASE.sql` | Creates and selects the project database |
| `CHECKDB.sql` | Checks that the four imported tables can be queried and reviews row counts |
| `QUERRIES.sql` | Exploratory queries for inventory, sales, supplier, stockout, and data-quality analysis |
| `joinquerries.sql` | Join practice for products and sales, including products without sales |
| `joinquerries1.sql` | Analysis of inventory value for items without sales in the latest sales month |
| `BUSINESS_QUESTIONS_SOLUTIONS.sql` | Consolidated MySQL solutions to all seven business questions |

## How to run the project

1. Open MySQL Workbench and run `DATABASE.sql`.
2. Import each CSV using **Table Data Import Wizard**, creating the four table names listed above. Keep the source column names and verify data types, especially the month fields and monetary columns.
3. Run `CHECKDB.sql` to confirm that the tables loaded.
4. Run `BUSINESS_QUESTIONS_SOLUTIONS.sql` to answer the seven business questions.

The CSV dataset is available from the source link above. The repository currently contains the SQL scripts and README; add the CSV files in a `data/` folder if you want the complete data package stored alongside the code.

## Important analysis and data-grain notes

- `items_and_stock` is a monthly snapshot table. Use the latest `Period` for current inventory and stock-value questions; summing stock value across all months would double-count historical snapshots.
- Sales and purchase tables also contain monthly facts. Aggregate them to the required level before joining them to another monthly fact table.
- The supplied `Weeks of cover` uses on-hand quantity. The replenishment-risk solution additionally calculates available-stock cover using `Qty available`, which accounts for allocated orders.
- `Stocked out (Y/N)` and `Lost sales units (stockout)` describe stockout demand during a month; they do not alone prove that end-of-month available stock is zero.
- Actual lead time is blank when no delivery was recorded. Those blank rows are excluded from supplier lead-time averages and late-delivery rates.
- The AP dataset represents the November 2026 open-bill snapshot. Use its supplied days-overdue values rather than recalculating overdue status against today's date.

## Tools and skills demonstrated

- MySQL 8.0
- Data profiling and validation
- Joins, CTEs, subqueries, and aggregations
- Window functions and ranking
- Date and period analysis
- Inventory coverage and replenishment analysis
- Supplier performance and purchase price variance
- Slow-moving inventory reserve analysis
- Accounts-payable aging and prioritization
