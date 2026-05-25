-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 02_search_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Especiales y de Búsqueda
-- DESCRIPCIÓN: Consultas demostrativas sobre el módulo relacional PostgreSQL:
--              * Búsqueda por SKU.
--              * Búsqueda aproximada sobre vendedores mediante pg_trgm.
--              * Consulta de promociones activas mediante TSTZRANGE.
--              * Consulta geográfica mediante PostGIS.
-- ============================================================================

-- Búsqueda exacta por SKU de producto
SELECT
    product_id,
    sku,
    created_at,
    updated_at
FROM products
WHERE sku = 'LAP-RYZ7-RTX4060-001';


-- Búsqueda tolerante a errores sobre nombre del vendedor con pg_trgm
SELECT
    seller_id,
    seller_name,
    similarity(seller_name, 'Tech Seler Brasil') AS similarity_score
FROM sellers
WHERE seller_name % 'Tech Seler Brasil'
ORDER BY similarity_score DESC;


-- Promociones vigentes según la fecha de prueba del seed
SELECT
    pr.promotion_id,
    p.sku,
    pr.promotion_name,
    pr.discount_percentage,
    pr.promotion_period
FROM promotions pr
         JOIN products p
              ON pr.product_id = p.product_id
WHERE pr.promotion_period @> TIMESTAMPTZ '2026-01-15 10:30:00-05';


-- Distancia entre cliente y vendedor
SELECT
    c.customer_id,
    s.seller_id,
    cg.city AS customer_city,
    sg.city AS seller_city,
    ROUND(
            ST_Distance(cg.coordinates, sg.coordinates)::numeric / 1000,
            2
    ) AS distance_km
FROM customers c
         JOIN geolocation cg
              ON c.geolocation_id = cg.geolocation_id
         JOIN sellers s
              ON s.seller_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
         JOIN geolocation sg
              ON s.geolocation_id = sg.geolocation_id
WHERE c.customer_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';


-- Pagos aprobados por gateway
SELECT
    payment_id,
    payment_type,
    payment_value,
    gateway_response ->> 'provider' AS provider,
    gateway_response ->> 'status' AS gateway_status,
    gateway_response ->> 'authorization_code' AS authorization_code
FROM payments
WHERE gateway_response @> '{"status": "APPROVED"}'::jsonb;