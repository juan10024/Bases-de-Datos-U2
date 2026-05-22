-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 03_olap_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Analíticas (OLAP)
-- DESCRIPCIÓN: Consultas de agregación y reportes de inteligencia de negocio:
--              * Refresco de vistas materializadas (`mv_sales_by_category_monthly`
--                y `mv_customer_segments`).
--              * Análisis e informes mensuales de ventas por categoría.
--              * Reporte de segmentación de clientes por volumen de gasto.
-- ============================================================================

-- Refrescar vistas materializadas
REFRESH MATERIALIZED VIEW mv_sales_by_category_monthly;
REFRESH MATERIALIZED VIEW mv_customer_segments;

-- Ventas mensuales por categoría
SELECT
    category_name,
    sales_month,
    total_orders,
    total_units,
    gross_sales,
    total_freight
FROM mv_sales_by_category_monthly
ORDER BY sales_month DESC, gross_sales DESC;

-- Segmentación de clientes
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    AVG(total_spent) AS avg_spent
FROM mv_customer_segments
GROUP BY customer_segment
ORDER BY avg_spent DESC;