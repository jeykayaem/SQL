# Retail Inventory Analytics

A SQL portfolio project focused on inventory performance, demand trends, replenishment risk, purchasing activity, and supplier payables for an industrial distribution business.

## Business Objective

Use item-level and monthly operational data to help the business answer questions such as:

- Which items have low stock coverage or are at risk of stockout?
- Which products and categories generate the most sales and revenue?
- Where are lost sales occurring because inventory was unavailable?
- How reliable are supplier lead times?
- Are purchasing costs above or below standard cost?
- Which items are slow-moving and may require an inventory reserve?
- What supplier bills remain unpaid, and which are overdue?

The goal is to turn operational data into practical recommendations for inventory planning, purchasing, and working-capital management.

## Dataset

The project dataset is synthetic. Company, item, supplier, and transaction values are fictional and suitable for portfolio practice.

- **Business type:** Industrial distribution
- **Currency:** USD
- **Monthly history:** December 2021 to November 2026
- **Latest reporting month:** November 2026
- **Source:** [Inventory Data Studio](https://inventoryoptimization.pro/inventory-data-studio/)

### Source files

| File | Rows | Purpose |
|---|---:|---|
| `items_and_stock.csv` | 9,000 | Monthly item-level stock, cost, selling price, lead-time, sales, stockout, and stock-cover information |
| `sales_by_item_month.csv` | 8,551 | Monthly item sales, units sold, revenue, and cost of goods sold |
| `purchases_by_item_month.csv` | 6,098 | Monthly receipts, supplier cost, freight and duty, landed value, standard cost, and purchase price variance |
| `ap_open_bills.csv` | 68 | Supplier bills outstanding at November 2026, including due dates and planned payment dates |

### Data relationships

- Use **Item code** with the relevant month/period to connect item-level stock, sales, and purchasing records.
- The open-bills file is a supplier-payables dataset. It supports accounts-payable and overdue-bill analysis.
- Check the grain of each table before joining. Aggregate monthly facts to the required level first to avoid multiplying quantities or values.

## Planned SQL Analysis

The SQL work will be organized into clear, reusable scripts covering:

1. Database setup, table creation, and data loading
2. Data-quality checks, null handling, duplicate checks, and reconciliation
3. Inventory position and stock valuation
4. Demand trends, average weekly demand, and weeks of cover
5. Stockout analysis and estimated lost sales
6. Replenishment prioritization using stock, demand, and supplier lead time
7. Purchasing analysis and purchase price variance
8. Supplier lead-time performance
9. Slow-moving inventory and reserve analysis
10. Accounts-payable aging and planned payments
11. CTEs, subqueries, joins, aggregations, and window-function analysis

## Key Metrics to Explore

- On-hand quantity and available quantity
- Inventory value and average landed cost
- Units sold and sales revenue
- Weeks of cover
- Lost sales units and stockout rate
- Actual versus planned supplier lead time
- Purchase price variance
- Slow-moving inventory reserve
- Open accounts-payable balance and overdue bills

Metric definitions and filters should be documented in the SQL scripts so that results can be reproduced and reconciled.

## Repository Structure

```text
RetailInventoryAnalytics/
├── README.md
├── data/
│   └── (source CSV files)
├── sql/
│   └── (SQL setup, validation, and analysis scripts)
└── insights/
    └── (business findings and recommendations)
```

## Tools and Skills

- MySQL / SQL
- Relational data analysis
- Data validation and reconciliation
- Joins, CTEs, subqueries, and aggregations
- Window functions and date analysis
- Inventory and operations analytics

## Project Status

The project README and analysis structure are being established. Add the source CSV files under `data/` and the project SQL scripts under `sql/` as they are made available. Findings and recommendations should be added under `insights/`.

