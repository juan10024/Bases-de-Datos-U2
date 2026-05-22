-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 04_indexes.sql
-- MÓDULO: Módulo Relacional - Esquema
-- DESCRIPCIÓN: Creación de índices optimizados para el esquema relacional.
--              Incluye índices B-Tree estándar para optimizar consultas de
--              búsqueda y uniones (FKs), índices GIN para atributos semiestructurados
--              (JSONB) y colecciones (arreglos), índice GIN con `pg_trgm` para
--              búsquedas difusas en nombres de productos, e índices GiST para
--              datos geográficos (PostGIS) y rangos temporales (TSTZRANGE).
-- ============================================================================

CREATE INDEX idx_customers_email
    ON customers(email);

CREATE INDEX idx_customers_geolocation
    ON customers(geolocation_id);

CREATE INDEX idx_sellers_geolocation
    ON sellers(geolocation_id);

CREATE INDEX idx_orders_customer_date
    ON orders(customer_id, purchase_timestamp);

CREATE INDEX idx_orders_status
    ON orders(order_status);

CREATE INDEX idx_order_items_order
    ON order_items(order_id, purchase_timestamp);

CREATE INDEX idx_order_items_product
    ON order_items(product_id);

CREATE INDEX idx_order_items_seller
    ON order_items(seller_id);

CREATE INDEX idx_payments_order
    ON payments(order_id, purchase_timestamp);

CREATE INDEX idx_products_category
    ON products(category_id);

CREATE INDEX idx_products_specs_gin
    ON products USING GIN(product_specifications);

CREATE INDEX idx_products_images_gin
    ON products USING GIN(product_images);

CREATE INDEX idx_products_name_trgm
    ON products USING GIN(product_name gin_trgm_ops);

CREATE INDEX idx_geolocation_coordinates
    ON geolocation USING GIST(coordinates);

CREATE INDEX idx_promotions_period
    ON promotions USING GIST(promotion_period);