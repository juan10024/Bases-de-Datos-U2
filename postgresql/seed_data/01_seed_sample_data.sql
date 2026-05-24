-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 01_seed_sample_data.sql
-- MÓDULO: Módulo Relacional - Datos Iniciales
-- DESCRIPCIÓN: Inserción de un conjunto consistente de datos iniciales
--              para pruebas de las tablas de geolocalización,
--              clientes, vendedores, productos (esquema híbrido minimalista),
--              órdenes (particionadas), detalles de orden, pagos y promociones.
-- ============================================================================

-- Seed geolocation
INSERT INTO geolocation (
    geolocation_id,
    zip_code,
    city,
    state,
    coordinates
)
VALUES
    (
        '11111111-1111-1111-1111-111111111111',
        '01000',
        'São Paulo',
        'SP',
        ST_GeogFromText('POINT(-46.6333 -23.5505)')
    ),
    (
        '22222222-2222-2222-2222-222222222222',
        '20000',
        'Rio de Janeiro',
        'RJ',
        ST_GeogFromText('POINT(-43.1729 -22.9068)')
    );

-- Seed customers
INSERT INTO customers (
    customer_id,
    customer_unique_id, 
    first_name,
    last_name,
    email,
    phone,
    geolocation_id
)
VALUES
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '99999999-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'Pepito',
        'Perez',
        'pepito@email.com',
        '3001234567',
        '11111111-1111-1111-1111-111111111111'
    );

-- Seed sellers
INSERT INTO sellers (
    seller_id,
    seller_name,
    email,
    geolocation_id
)
VALUES
    (
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'Tech Seller Brasil',
        'seller@ecommify.com',
        '22222222-2222-2222-2222-222222222222'
    );

-- Seed products
INSERT INTO products (
    product_id,
    sku
)
VALUES
    (
        'dddddddd-dddd-dddd-dddd-dddddddddddd',
        'LAP-RYZ7-RTX4060-001'
    );

-- Seed orders
INSERT INTO orders (
    order_id,
    customer_id,
    order_status,
    purchase_timestamp,
    total_amount
)
VALUES
    (
        'ffffffff-ffff-ffff-ffff-ffffffffffff',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'APPROVED',
        '2026-01-15 10:30:00',
        1500000.00
    );

-- Seed order items
INSERT INTO order_items (
    order_item_id,
    order_id,
    purchase_timestamp,
    product_id,
    seller_id,
    quantity,
    price,
    freight_value,
    shipping_limit_date
)
VALUES
    (
        '99999999-9999-9999-9999-999999999999',
        'ffffffff-ffff-ffff-ffff-ffffffffffff',
        '2026-01-15 10:30:00',
        'dddddddd-dddd-dddd-dddd-dddddddddddd',
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        1,
        1500000.00,
        35000.00,
        '2026-01-20 23:59:59'
    );

-- Seed payments
INSERT INTO payments (
    payment_id,
    order_id,
    purchase_timestamp,
    payment_type,
    payment_installments,
    payment_value
)
VALUES
    (
        '88888888-8888-8888-8888-888888888888',
        'ffffffff-ffff-ffff-ffff-ffffffffffff',
        '2026-01-15 10:30:00',
        'CREDIT_CARD',
        3,
        1500000.00
    );

-- Seed promotions
INSERT INTO promotions (
    promotion_id,
    product_id,
    promotion_name,
    discount_percentage,
    promotion_period
)
VALUES
    (
        '77777777-7777-7777-7777-777777777777',
        'dddddddd-dddd-dddd-dddd-dddddddddddd',
        'January Tech Promo',
        10.00,
        TSTZRANGE('2026-01-01 00:00:00-05', '2026-02-01 00:00:00-05')
    );