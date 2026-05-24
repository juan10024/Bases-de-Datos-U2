-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 03_olap_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Analíticas OLAP
-- DESCRIPCIÓN: Definición, refresco y consulta de vistas materializadas
--              orientadas a Business Intelligence:
--              * Análisis geográfico y mensual de rendimiento financiero.
--              * Segmentación de clientes.
-- ============================================================================

-- Análisis de Ventas Geo-Temporales
CREATE MATERIALIZED VIEW mv_sales_by_region_monthly AS
SELECT
    g.state AS customer_state,
    DATE_TRUNC('month', o.purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units,
    SUM(oi.price * oi.quantity) AS gross_sales,
    SUM(oi.freight_value) AS total_freight
FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN geolocation g ON c.geolocation_id = g.geolocation_id
    JOIN order_items oi ON o.order_id = oi.order_id AND o.purchase_timestamp = oi.purchase_timestamp
GROUP BY g.state, DATE_TRUNC('month', o.purchase_timestamp)
WITH NO DATA;

-- Segmentación de Clientes por Volumen de Gasto Histórico
CREATE MATERIALIZED VIEW mv_customer_segments AS
SELECT
    c.customer_unique_id,
    SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) >= 2000000 THEN 'VIP'
        WHEN SUM(o.total_amount) BETWEEN 500000 AND 1999999 THEN 'REGULAR_ALTO'
        ELSE 'REGULAR_BAJO'
    END AS customer_segment
FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
WITH NO DATA;


-- OPERACIONES DE REFRESCO

REFRESH MATERIALIZED VIEW mv_sales_by_region_monthly;
REFRESH MATERIALIZED VIEW mv_customer_segments;


-- CONSULTAS DE REPORTING ANALÍTICO

-- Desempeño comercial por Estado y Mes
SELECT
    customer_state,
    TO_CHAR(sales_month, 'YYYY-MM') AS periodo,
    total_orders,
    total_units,
    gross_sales,
    total_freight
FROM mv_sales_by_region_monthly
ORDER BY sales_month DESC, gross_sales DESC;


-- Distribución y concentración del ingreso por segmento de cliente
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    SUM(total_spent) AS total_revenue_contribution,
    ROUND(AVG(total_spent), 2) AS avg_spent_per_customer
FROM mv_customer_segments
GROUP BY customer_segment
ORDER BY avg_spent_per_customer DESC;