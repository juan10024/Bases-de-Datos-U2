-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 03_olap_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Analíticas OLAP
-- DESCRIPCIÓN:  * Análisis mensual de rendimiento financiero por vendedor.
--               * Segmentación de clientes.
-- ============================================================================


-- OPERACIONES DE REFRESCO

REFRESH MATERIALIZED VIEW mv_sales_by_seller_monthly;
REFRESH MATERIALIZED VIEW mv_customer_segments;


-- CONSULTAS DE REPORTING ANALÍTICO

SELECT
    seller_id,
    seller_name,
    TO_CHAR(sales_month, 'YYYY-MM') AS periodo,
    total_orders,
    total_units,
    gross_sales,
    total_freight
FROM mv_sales_by_seller_monthly
ORDER BY sales_month DESC, gross_sales DESC;

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    SUM(total_spent) AS total_revenue_contribution,
    ROUND(AVG(total_spent), 2) AS avg_spent_per_customer
FROM mv_customer_segments
GROUP BY customer_segment
ORDER BY avg_spent_per_customer DESC;