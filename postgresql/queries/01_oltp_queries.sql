-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 01_oltp_queries.sql
-- MÓDULO: Módulo Relacional - Consultas Transaccionales (OLTP)
-- DESCRIPCIÓN: Consultas orientadas a operaciones transaccionales diarias:
--              * Historial de pedidos por cliente.
--              * Detalle completo e ítems asociados a un pedido específico.
--              * Inventario actual y stock disponible por producto y vendedor.
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
    p.product_name,
    oi.quantity,
    oi.price,
    oi.freight_value,
    pay.payment_type,
    pay.payment_installments,
    pay.payment_value
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

-- Inventario disponible por producto y vendedor
SELECT
    p.product_name,
    s.seller_name,
    i.stock_quantity,
    i.reserved_quantity,
    (i.stock_quantity - i.reserved_quantity) AS available_stock
FROM inventory i
         JOIN products p ON i.product_id = p.product_id
         JOIN sellers s ON i.seller_id = s.seller_id
WHERE p.product_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';