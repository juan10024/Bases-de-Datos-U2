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