-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 01_tables.sql
-- MÓDULO: Módulo Relacional - Esquema
-- DESCRIPCIÓN: Creación de las tablas principales del modelo relacional
--              normalizado a 3FN para Ecommify. Incluye llaves primarias, foráneas,
--              restricciones CHECK y la especificación de particionamiento
--              para la tabla de órdenes por fecha de compra.
-- ============================================================================

-- geolocation
CREATE TABLE geolocation (
    geolocation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zip_code VARCHAR(15) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state CHAR(2) NOT NULL,
    coordinates GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- customers
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_unique_id UUID NOT NULL, 
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    geolocation_id UUID REFERENCES geolocation(geolocation_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_customer_email UNIQUE (customer_unique_id, email)
);

-- sellers
CREATE TABLE sellers (
    seller_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    geolocation_id UUID REFERENCES geolocation(geolocation_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- products
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- orders
CREATE TABLE orders (
    order_id UUID NOT NULL DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(customer_id),
    order_status VARCHAR(30) NOT NULL DEFAULT 'CREATED',
    purchase_timestamp TIMESTAMP NOT NULL,
    delivered_timestamp TIMESTAMP,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, purchase_timestamp)
) PARTITION BY RANGE (purchase_timestamp);

-- order_items
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    purchase_timestamp TIMESTAMP NOT NULL,
    product_id UUID NOT NULL REFERENCES products(product_id),
    seller_id UUID NOT NULL REFERENCES sellers(seller_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    freight_value NUMERIC(10,2) DEFAULT 0 CHECK (freight_value >= 0),
    shipping_limit_date TIMESTAMP,
    FOREIGN KEY (order_id, purchase_timestamp) REFERENCES orders(order_id, purchase_timestamp)
);

-- payments
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    purchase_timestamp TIMESTAMP NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INTEGER DEFAULT 1 CHECK (payment_installments > 0),
    payment_value NUMERIC(12,2) NOT NULL CHECK (payment_value >= 0),
    gateway_response JSONB,
    payment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id, purchase_timestamp) REFERENCES orders(order_id, purchase_timestamp)
);

-- promotions
CREATE TABLE promotions (
    promotion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(product_id),
    promotion_name VARCHAR(150) NOT NULL,
    discount_percentage NUMERIC(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    promotion_period TSTZRANGE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);