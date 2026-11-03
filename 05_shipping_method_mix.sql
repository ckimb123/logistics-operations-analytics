-- LOGISTICS OPERATIONS ANALYTICS | 05: SHIPPING METHOD MIX
USE logistics_analytics;

-- Original window-function approach: share of each center's shipments
-- by shipping method. Includes all shipment records.
SELECT center_id, shipping_method,
       COUNT(*) AS method_shipments,
       SUM(COUNT(*)) OVER (PARTITION BY center_id) AS center_shipments,
       ROUND(100.0 * COUNT(*) /
             SUM(COUNT(*)) OVER (PARTITION BY center_id), 2) AS method_pct
FROM shipments
GROUP BY center_id, shipping_method
ORDER BY center_id ASC, method_shipments DESC;
