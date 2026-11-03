-- LOGISTICS OPERATIONS ANALYTICS | 03: TRANSPORTATION COST
USE logistics_analytics;

-- Average and total transportation cost by distribution center.
SELECT center_id, COUNT(*) AS total_shipments,
       ROUND(AVG(transport_cost_usd), 2) AS avg_transport_cost_usd,
       ROUND(SUM(transport_cost_usd), 2) AS total_transport_cost_usd
FROM shipments
GROUP BY center_id ORDER BY total_transport_cost_usd DESC;

-- Cost by shipping method: total costs reflect volume as well as unit cost.
SELECT shipping_method, COUNT(*) AS total_shipments,
       ROUND(AVG(transport_cost_usd), 2) AS avg_transport_cost_usd,
       ROUND(SUM(transport_cost_usd), 2) AS total_transport_cost_usd
FROM shipments
GROUP BY shipping_method ORDER BY avg_transport_cost_usd DESC;
