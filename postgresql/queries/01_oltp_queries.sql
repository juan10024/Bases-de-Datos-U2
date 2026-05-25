-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 01_oltp_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Transaccionales (OLTP)
-- DESCRIPCIÓN: Consultas orientadas a operaciones transaccionales diarias:
--              * Historial de pedidos por cliente.
--              * Detalle completo e ítems asociados a un pedido específico.
--              * Promociones activas por producto usando operadores de rango.
-- ============================================================================

-- Historial de pedidos por cliente
SELECT
    o.order_id,
    o.order_status,
    o.purchase_timestamp,
    o.total_amount
FROM orders o
WHERE o.customer_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
ORDER BY o.purchase_timestamp DESC;


-- Detalle completo de un pedido 
SELECT
    o.order_id,
    o.order_status,
    p.sku, 
    oi.quantity,
    oi.price,
    oi.freight_value,
    pay.payment_type,
    pay.payment_installments,
    pay.payment_value,
    pay.gateway_response ->> 'provider' AS payment_provider,
    pay.gateway_response ->> 'authorization_code' AS authorization_code,
    pay.gateway_response ->> 'status' AS gateway_status
FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id 
        AND o.purchase_timestamp = oi.purchase_timestamp
    JOIN products p 
        ON oi.product_id = p.product_id
    JOIN payments pay 
        ON o.order_id = pay.order_id 
        AND o.purchase_timestamp = pay.purchase_timestamp
WHERE o.order_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';


-- Promociones vigentes para un producto específico
SELECT 
    promotion_name,
    discount_percentage,
    promotion_period
FROM promotions
WHERE product_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'
  AND promotion_period @> TIMESTAMPTZ '2026-01-15 10:30:00-05';