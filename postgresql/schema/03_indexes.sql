-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 03_indexes.sql
-- MÓDULO: Módulo Relacional - Esquema
-- DESCRIPCIÓN: Creación de índices optimizados para el esquema relacional.
--              Incluye índices B-Tree para búsquedas frecuentes, joins,
--              claves foráneas y filtros transaccionales; además, índices GiST
--              para datos geográficos mediante PostGIS y rangos temporales
--              mediante TSTZRANGE.
-- ============================================================================

CREATE INDEX idx_customers_unique_id
    ON customers(customer_unique_id);

CREATE INDEX idx_customers_email
    ON customers(email);

CREATE INDEX idx_customers_geolocation
    ON customers(geolocation_id);

CREATE INDEX idx_sellers_email
    ON sellers(email);

CREATE INDEX idx_sellers_geolocation
    ON sellers(geolocation_id);

CREATE INDEX idx_products_sku
    ON products(sku);

CREATE INDEX idx_orders_customer_date
    ON orders(customer_id, purchase_timestamp);

CREATE INDEX idx_orders_status
    ON orders(order_status);

CREATE INDEX idx_orders_purchase_timestamp
    ON orders(purchase_timestamp);

CREATE INDEX idx_order_items_order
    ON order_items(order_id, purchase_timestamp);

CREATE INDEX idx_order_items_product
    ON order_items(product_id);

CREATE INDEX idx_order_items_seller
    ON order_items(seller_id);

CREATE INDEX idx_payments_order
    ON payments(order_id, purchase_timestamp);

CREATE INDEX idx_geolocation_coordinates
    ON geolocation USING GIST(coordinates);

CREATE INDEX idx_promotions_product
    ON promotions(product_id);

CREATE INDEX idx_promotions_period
    ON promotions USING GIST(promotion_period);

CREATE INDEX idx_payments_gateway_response_gin
    ON payments USING GIN(gateway_response);

CREATE INDEX idx_mv_sales_by_seller_monthly
    ON mv_sales_by_seller_monthly(seller_id, sales_month);