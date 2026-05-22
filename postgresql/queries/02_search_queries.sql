-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 02_search_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Especiales y de Búsqueda
-- DESCRIPCIÓN: Consultas demostrativas de características avanzadas en PostgreSQL:
--              * Coincidencia difusa y tolerancia a errores tipográficos usando pg_trgm.
--              * Consultas y filtros sobre documentos JSONB (especificaciones técnicas).
--              * Desanidado (unnest) de colecciones/arreglos para imágenes de productos.
--              * Filtrado dinámico de promociones mediante exclusión/pertenencia en tstzrange.
-- ============================================================================

-- Búsqueda tolerante a errores con pg_trgm
SELECT
    product_id,
    product_name,
    similarity(product_name, 'laptp ryzen') AS similarity_score
FROM products
WHERE product_name % 'laptp ryzen'
ORDER BY similarity_score DESC;

-- Consulta sobre atributos JSONB
SELECT
    product_id,
    product_name,
    product_specifications ->> 'ram' AS ram,
    product_specifications ->> 'cpu' AS cpu
FROM products
WHERE product_specifications @> '{"ram": "16GB"}';

-- Consulta sobre imágenes almacenadas en arreglo
SELECT
    product_id,
    product_name,
    unnest(product_images) AS image_url
FROM products;

-- Promociones activas
SELECT
    promotion_id,
    promotion_name,
    discount_percentage
FROM promotions
WHERE promotion_period @> CURRENT_TIMESTAMP;