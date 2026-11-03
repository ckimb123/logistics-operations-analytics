-- LOGISTICS OPERATIONS ANALYTICS | 02: DELIVERY PERFORMANCE
USE logistics_analytics;

-- Overall KPIs; invalid delivery chronology is excluded from rates.
SELECT COUNT(*) AS valid_shipments,
       SUM(CASE WHEN actual_delivery_date <= promised_delivery_date THEN 1 ELSE 0 END) AS on_time_shipments,
       SUM(CASE WHEN actual_delivery_date > promised_delivery_date THEN 1 ELSE 0 END) AS late_shipments,
       ROUND(100.0 * AVG(CASE WHEN actual_delivery_date <= promised_delivery_date THEN 1.0 ELSE 0.0 END), 2) AS on_time_rate_pct
FROM shipments
WHERE data_quality_flag = 'VALID';

-- On-time rate by distribution center.
SELECT center_id, COUNT(*) AS valid_shipments,
       SUM(CASE WHEN actual_delivery_date <= promised_delivery_date THEN 1 ELSE 0 END) AS on_time_shipments,
       ROUND(100.0 * AVG(CASE WHEN actual_delivery_date <= promised_delivery_date THEN 1.0 ELSE 0.0 END), 2) AS on_time_rate_pct
FROM shipments
WHERE data_quality_flag = 'VALID'
GROUP BY center_id ORDER BY on_time_rate_pct ASC;

-- On-time rate by shipping method.
SELECT shipping_method, COUNT(*) AS valid_shipments,
       ROUND(100.0 * AVG(CASE WHEN actual_delivery_date <= promised_delivery_date THEN 1.0 ELSE 0.0 END), 2) AS on_time_rate_pct
FROM shipments
WHERE data_quality_flag = 'VALID'
GROUP BY shipping_method ORDER BY on_time_rate_pct DESC;

-- Original investigation: delay reasons for late Next Day shipments.
SELECT delay_reason, COUNT(*) AS total_delays
FROM shipments
WHERE shipping_method = 'Next Day'
  AND actual_delivery_date > promised_delivery_date
  AND data_quality_flag = 'VALID'
GROUP BY delay_reason ORDER BY total_delays DESC;
