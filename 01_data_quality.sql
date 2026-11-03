-- LOGISTICS OPERATIONS ANALYTICS | 01: DATA QUALITY
USE logistics_analytics;

-- Confirm final shipment count, uniqueness, and center coverage.
SELECT COUNT(*) AS total_shipments,
       COUNT(DISTINCT shipment_id) AS unique_shipments,
       COUNT(DISTINCT center_id) AS centers
FROM shipments;

-- Flagged invalid delivery chronology (preserved for audit).
SELECT data_quality_flag, COUNT(*) AS shipment_count
FROM shipments
GROUP BY data_quality_flag;

-- Verify chronology independently of flag.
SELECT SUM(CASE WHEN actual_delivery_date < ship_date THEN 1 ELSE 0 END)
           AS invalid_delivery_before_ship,
       SUM(CASE WHEN actual_delivery_date >= ship_date THEN 1 ELSE 0 END)
           AS date_order_valid
FROM shipments;

-- Check missing values in the staging table before conversion.
SELECT
  SUM(shipment_id IS NULL OR TRIM(shipment_id) = '') AS missing_shipment_ids,
  SUM(center_id IS NULL OR TRIM(center_id) = '') AS missing_center_ids,
  SUM(ship_date IS NULL OR TRIM(ship_date) = '') AS missing_ship_dates,
  SUM(promised_delivery_date IS NULL OR TRIM(promised_delivery_date) = '') AS missing_promised_dates,
  SUM(actual_delivery_date IS NULL OR TRIM(actual_delivery_date) = '') AS missing_actual_dates,
  SUM(transport_cost_usd IS NULL OR TRIM(transport_cost_usd) = '') AS missing_transport_costs
FROM shipments_staging;

-- Original project check: missing delay reasons are not proof of on-time arrival.
SELECT delay_reason, COUNT(*) AS shipment_count
FROM shipments GROUP BY delay_reason ORDER BY shipment_count DESC;

-- Late shipments without documented delay reasons.
SELECT shipment_id, promised_delivery_date, actual_delivery_date, delay_reason
FROM shipments
WHERE data_quality_flag = 'VALID'
  AND actual_delivery_date > promised_delivery_date
  AND delay_reason IS NULL;
