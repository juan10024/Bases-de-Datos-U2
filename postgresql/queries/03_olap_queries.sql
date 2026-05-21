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