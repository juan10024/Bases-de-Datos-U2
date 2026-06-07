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

-- 1. Geolocalizaciones
INSERT INTO geolocation (
    geolocation_id,
    zip_code,
    city,
    state,
    coordinates
)
SELECT
    gen_random_uuid(),
    LPAD((10000 + gs)::TEXT, 5, '0'),
    'City_' || gs,
    (ARRAY['SP','RJ','MG','PR','SC','RS','BA','PE','GO','CE'])[1 + floor(random() * 10)::int],
    ST_SetSRID(
        ST_MakePoint(
            -74 + random() * 20,
            -33 + random() * 25
        ),
        4326
    )::geography
FROM generate_series(1, 1000) gs;

-- 2. Clientes
INSERT INTO customers (
    customer_id,
    customer_unique_id,
    first_name,
    last_name,
    email,
    phone,
    geolocation_id
)
SELECT
    gen_random_uuid(),
    gen_random_uuid(),
    'Customer_' || gs,
    'LastName_' || gs,
    'customer_' || gs || '@ecommify.com',
    '300' || LPAD(gs::TEXT, 7, '0'),
    (
        SELECT geolocation_id
        FROM geolocation
        ORDER BY random()
        LIMIT 1
    )
FROM generate_series(1, 50000) gs;


-- 3. Vendedores
INSERT INTO sellers (
    seller_id,
    seller_name,
    email,
    geolocation_id
)
SELECT
    gen_random_uuid(),
    'Seller_' || gs,
    'seller_' || gs || '@ecommify.com',
    (
        SELECT geolocation_id
        FROM geolocation
        ORDER BY random()
        LIMIT 1
    )
FROM generate_series(1, 5000) gs;

-- 4. Productos
INSERT INTO products (
    product_id,
    sku
)
SELECT
    gen_random_uuid(),
    'SKU-' || gs || '-' || substr(md5(random()::text), 1, 8)
FROM generate_series(1, 20000) gs;

-- 5. Órdenes
INSERT INTO orders (
    order_id,
    customer_id,
    order_status,
    purchase_timestamp,
    delivered_timestamp,
    total_amount
)
SELECT
    gen_random_uuid(),
    (
        SELECT customer_id
        FROM customers
        ORDER BY random()
        LIMIT 1
    ),
    (ARRAY['CREATED','APPROVED','SHIPPED','DELIVERED','CANCELLED'])[1 + floor(random() * 5)::int],
    timestamp '2025-01-01'
        + (random() * interval '364 days'),
    timestamp '2025-01-01'
        + (random() * interval '364 days')
        + interval '3 days',
    ROUND((50 + random() * 2000000)::numeric, 2)
FROM generate_series(1, 300000) gs;

-- 6. Ítems de orden
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
SELECT
    gen_random_uuid(),
    o.order_id,
    o.purchase_timestamp,
    (
        SELECT product_id
        FROM products
        ORDER BY random()
        LIMIT 1
    ),
    (
        SELECT seller_id
        FROM sellers
        ORDER BY random()
        LIMIT 1
    ),
    1 + floor(random() * 5)::int,
    ROUND((20000 + random() * 1500000)::numeric, 2),
    ROUND((5000 + random() * 50000)::numeric, 2),
    o.purchase_timestamp + interval '7 days'
FROM orders o
    JOIN LATERAL generate_series(1, 1 + floor(random() * 4)::int) x(n)
ON true;

-- 7. Pagos
INSERT INTO payments (
    payment_id,
    order_id,
    purchase_timestamp,
    payment_type,
    payment_installments,
    payment_value,
    gateway_response,
    payment_timestamp
)
SELECT
    gen_random_uuid(),
    o.order_id,
    o.purchase_timestamp,
    (ARRAY['CREDIT_CARD','DEBIT_CARD','BOLETO','VOUCHER'])[1 + floor(random() * 4)::int],
    1 + floor(random() * 12)::int,
    o.total_amount,
    jsonb_build_object(
        'provider', (ARRAY['Stripe','PayU','MercadoPago','Adyen'])[1 + floor(random() * 4)::int],
        'status', (ARRAY['APPROVED','REJECTED','PENDING'])[1 + floor(random() * 3)::int],
        'authorization_code', 'AUTH-' || substr(md5(random()::text), 1, 10),
        'transaction_id', 'TXN-' || gen_random_uuid()
    ),
    o.purchase_timestamp + interval '5 minutes'
FROM orders o;

INSERT INTO promotions (
    promotion_id,
    product_id,
    promotion_name,
    discount_percentage,
    promotion_period
)
SELECT
    gen_random_uuid(),
    p.product_id,
    'Promo_' || gs,
    ROUND((5 + random() * 50)::numeric, 2),
    tstzrange(
            start_date,
            start_date + interval '30 days',
            '[)'
    )
FROM generate_series(1, 5000) gs
         CROSS JOIN LATERAL (
    SELECT timestamp '2025-01-01' + (random() * interval '300 days') AS start_date
        ) d
         CROSS JOIN LATERAL (
    SELECT product_id
    FROM products
    ORDER BY random()
        LIMIT 1
) p;