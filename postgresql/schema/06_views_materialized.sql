-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 06_views_materialized.sql
-- MÓDULO: Módulo Relacional - Esquema
-- DESCRIPCIÓN: Creación de vistas materializadas y sus respectivos índices.
--              Contiene:
--              * mv_sales_by_category_monthly: Agregado analítico mensual de
--                ventas brutas, fletes y volumen de pedidos agrupados por categoría.
--              * mv_customer_segments: Segmentación de clientes (HIGH_VALUE,
--                MEDIUM_VALUE, LOW_VALUE) basada en el total acumulado de compras.
-- ============================================================================

CREATE MATERIALIZED VIEW mv_sales_by_category_monthly AS
SELECT
    c.category_name,
    DATE_TRUNC('month', o.purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units,
    SUM(oi.price * oi.quantity) AS gross_sales,
    SUM(oi.freight_value) AS total_freight
FROM orders o
         JOIN order_items oi
              ON o.order_id = oi.order_id
                  AND o.purchase_timestamp = oi.purchase_timestamp
         JOIN products p
              ON oi.product_id = p.product_id
         JOIN categories c
              ON p.category_id = c.category_id
GROUP BY c.category_name, DATE_TRUNC('month', o.purchase_timestamp);

CREATE MATERIALIZED VIEW mv_customer_segments AS
SELECT
    c.customer_id,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    MAX(o.purchase_timestamp) AS last_purchase,
    CASE
        WHEN SUM(o.total_amount) >= 5000000 THEN 'HIGH_VALUE'
        WHEN SUM(o.total_amount) >= 1000000 THEN 'MEDIUM_VALUE'
        ELSE 'LOW_VALUE'
        END AS customer_segment
FROM customers c
         JOIN orders o
              ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email;

CREATE UNIQUE INDEX idx_mv_customer_segments_customer
    ON mv_customer_segments(customer_id);