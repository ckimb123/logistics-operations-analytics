# SQL Analysis — Logistics Operations Portfolio

These scripts organize the author's original MySQL analysis of **15,000 simulated shipments**. They demonstrate relational schema design, raw-data staging, type conversion, data-quality flags, KPI analysis, window functions, and investigation of Atlanta/Seattle delivery delays.

## File order
1. `00_database_setup_and_cleaning.sql` — schema, staging, import checks, conversion and flagging
2. `01_data_quality.sql` — duplicates, missing fields, invalid chronology, delay-reason checks
3. `02_delivery_performance.sql` — overall, center and shipping-method on-time rates
4. `03_transport_cost.sql` — average and total cost by center/method
5. `04_shipping_distance.sql` — distance and cost comparisons
6. `05_shipping_method_mix.sql` — window-function method share by center
7. `06_atlanta_seattle_investigation.sql` — sorting/capacity delay analysis

## How to run
- MySQL 8+ is required for the window function.
- Run `00` in sections. Import the distribution-center CSV into `distribution_centers` and the raw shipment CSV into `shipments_staging` with MySQL Workbench **before** the INSERT section. The CSV files are not included here.
- The raw source dates in the original project were formatted `MM/DD/YYYY` and are converted using `STR_TO_DATE(..., '%c/%e/%Y')`.
- Verify data quality before loading. The staging import is not automated; data imports and numeric casts require valid source data.
- If the existing database was created previously, the script preserves its tables; it is not intended to rebuild an existing database from scratch.
- Run scripts `01`–`06` after the data is loaded. Query outputs are not included in the SQL files.

## Previously reported results (verify in your environment)
- Total: 15,000; invalid delivery chronology: 393; valid: 14,607.
- On-time deliveries: 12,259; valid-record on-time rate: 83.93%.
- ATL: 75.74% on-time; SEA: 87.74% on-time.
- Ground: 84.52% on-time, $71.66 average cost; Next Day: 79.24%, $107.25.

## Important notes
- The original script was reorganized, formatted, and minimally refactored for a public portfolio. It was **not** executed against the original MySQL database in this environment.
- Invalid delivery dates are **retained** and flagged; excluded from on-time calculations.
- Shipping-cost queries include all records, consistent with the original analysis.
- The flagging rule covers `actual_delivery_date < ship_date`. Additional missing/invalid-date conditions would require a broader quality policy.
- The original project includes an independent Jupyter dashboard. This SQL folder does not reproduce its image by itself.
- Educational project using simulated data; not affiliated with or endorsed by DHL.
