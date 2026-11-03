-- LOGISTICS OPERATIONS ANALYTICS | 00: DATABASE SETUP & CLEANING
-- MySQL 8+ | Simulated shipment data
-- Run in sections. Import distribution_centers and shipments_staging CSVs
-- using MySQL Workbench between schema creation and validation.
-- Existing tables are preserved: no DROP/TRUNCATE operations.
-- This script is not an automatic CSV importer.

CREATE DATABASE IF NOT EXISTS logistics_analytics;
USE logistics_analytics;

CREATE TABLE IF NOT EXISTS distribution_centers (
    center_id VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS shipments (
    shipment_id VARCHAR(50) PRIMARY KEY,
    center_id VARCHAR(10),
    ship_date DATE,
    promised_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_method VARCHAR(50),
    distance_miles INT,
    package_weight_lb DECIMAL(10,2),
    transport_cost_usd DECIMAL(10,2),
    delay_reason VARCHAR(100),
    data_quality_flag VARCHAR(30),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(center_id)
);

CREATE TABLE IF NOT EXISTS shipments_staging (
    shipment_id VARCHAR(50),
    center_id VARCHAR(50),
    ship_date VARCHAR(30),
    promised_delivery_date VARCHAR(30),
    actual_delivery_date VARCHAR(30),
    shipping_method VARCHAR(50),
    distance_miles VARCHAR(30),
    package_weight_lb VARCHAR(30),
    transport_cost_usd VARCHAR(30),
    delay_reason VARCHAR(100)
);

-- IMPORT CHECKPOINT: Use MySQL Workbench to import center data into
-- distribution_centers, and raw shipment data into shipments_staging.
-- Do not execute the INSERT below until those imports are complete.
SELECT COUNT(*) AS center_count FROM distribution_centers;
SELECT COUNT(*) AS staged_rows,
       COUNT(DISTINCT shipment_id) AS unique_shipment_ids
FROM shipments_staging;

-- Review missing identifiers and raw date conversions before loading.
SELECT COUNT(*) AS missing_shipment_ids
FROM shipments_staging
WHERE shipment_id IS NULL OR TRIM(shipment_id) = '';

SELECT ship_date,
       STR_TO_DATE(ship_date, '%c/%e/%Y') AS converted_ship_date
FROM shipments_staging LIMIT 10;

SELECT COUNT(*) AS invalid_ship_dates
FROM shipments_staging
WHERE STR_TO_DATE(ship_date, '%c/%e/%Y') IS NULL;

SELECT COUNT(*) AS invalid_promised_dates
FROM shipments_staging
WHERE STR_TO_DATE(promised_delivery_date, '%c/%e/%Y') IS NULL;

SELECT COUNT(*) AS invalid_actual_dates
FROM shipments_staging
WHERE STR_TO_DATE(actual_delivery_date, '%c/%e/%Y') IS NULL;

SELECT DISTINCT s.center_id
FROM shipments_staging AS s
LEFT JOIN distribution_centers AS d ON TRIM(s.center_id) = d.center_id
WHERE d.center_id IS NULL;

SELECT shipment_id, transport_cost_usd
FROM shipments_staging
WHERE CAST(transport_cost_usd AS DECIMAL(10,2)) < 0;

-- Load cleaned values. NOT NULL validation and manual review of any bad
-- dates/IDs should precede this step. The anti-join avoids reinserting IDs.
-- MySQL Workbench source dates were MM/DD/YYYY in the original project.
INSERT INTO shipments (
    shipment_id, center_id, ship_date, promised_delivery_date,
    actual_delivery_date, shipping_method, distance_miles,
    package_weight_lb, transport_cost_usd, delay_reason, data_quality_flag
)
SELECT TRIM(s.shipment_id), TRIM(s.center_id),
       STR_TO_DATE(s.ship_date, '%c/%e/%Y'),
       STR_TO_DATE(s.promised_delivery_date, '%c/%e/%Y'),
       STR_TO_DATE(s.actual_delivery_date, '%c/%e/%Y'),
       TRIM(s.shipping_method), CAST(s.distance_miles AS UNSIGNED),
       CAST(s.package_weight_lb AS DECIMAL(10,2)),
       CAST(s.transport_cost_usd AS DECIMAL(10,2)),
       NULLIF(TRIM(s.delay_reason), ''),
       CASE
         WHEN STR_TO_DATE(s.actual_delivery_date, '%c/%e/%Y') <
              STR_TO_DATE(s.ship_date, '%c/%e/%Y')
         THEN 'INVALID DELIVERY DATE'
         ELSE 'VALID'
       END
FROM shipments_staging AS s
LEFT JOIN shipments AS existing ON existing.shipment_id = TRIM(s.shipment_id)
WHERE existing.shipment_id IS NULL;

-- Preserve all records; flag impossible delivery-before-shipping dates.
-- For preexisting rows imported before the flag was created, this updates
-- only the quality flag. Run with SQL_SAFE_UPDATES temporarily disabled.
SET @previous_sql_safe_updates = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
UPDATE shipments
SET data_quality_flag = CASE
    WHEN actual_delivery_date < ship_date THEN 'INVALID DELIVERY DATE'
    ELSE 'VALID'
END;
SET SQL_SAFE_UPDATES = @previous_sql_safe_updates;

SELECT data_quality_flag, COUNT(*) AS shipments
FROM shipments GROUP BY data_quality_flag;
-- Expected from the completed project: 15,000 total; 393 invalid dates.
