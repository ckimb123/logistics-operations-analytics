-- LOGISTICS OPERATIONS ANALYTICS | 04: SHIPPING DISTANCE
USE logistics_analytics;

-- Compare average shipment distance with average cost by center.
-- Descriptive comparison only; distance does not establish causality.
SELECT center_id, COUNT(*) AS total_shipments,
       ROUND(AVG(distance_miles), 2) AS avg_shipping_distance_miles,
       ROUND(AVG(transport_cost_usd), 2) AS avg_transport_cost_usd
FROM shipments
GROUP BY center_id
ORDER BY avg_transport_cost_usd DESC, avg_shipping_distance_miles;
