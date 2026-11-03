-- LOGISTICS OPERATIONS ANALYTICS | 06: ATLANTA VS SEATTLE
-- Preserves the user's original follow-up investigation.
USE logistics_analytics;

-- Late shipment delay reasons by center.
SELECT center_id, delay_reason, COUNT(*) AS total_delays
FROM shipments
WHERE center_id IN ('ATL', 'SEA')
  AND actual_delivery_date > promised_delivery_date
  AND data_quality_flag = 'VALID'
GROUP BY center_id, delay_reason
ORDER BY center_id, total_delays DESC;

-- Sorting and capacity delay incidence, using all valid shipments as denominator.
-- These are flagged delay reasons, not necessarily the sole causes of lateness.
SELECT center_id, COUNT(*) AS valid_shipments,
       SUM(CASE WHEN delay_reason = 'Sorting' THEN 1 ELSE 0 END) AS sorting_delays,
       ROUND(100.0 * AVG(CASE WHEN delay_reason = 'Sorting' THEN 1.0 ELSE 0.0 END), 2) AS sorting_delay_rate_pct,
       SUM(CASE WHEN delay_reason = 'Capacity' THEN 1 ELSE 0 END) AS capacity_delays,
       ROUND(100.0 * AVG(CASE WHEN delay_reason = 'Capacity' THEN 1.0 ELSE 0.0 END), 2) AS capacity_delay_rate_pct
FROM shipments
WHERE center_id IN ('ATL', 'SEA')
  AND data_quality_flag = 'VALID'
GROUP BY center_id
ORDER BY center_id;
