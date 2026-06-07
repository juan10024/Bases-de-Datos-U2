-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 02_partitions.sql
-- MÓDULO: Módulo Relacional - Esquema
-- DESCRIPCIÓN: Definición y creación física de las particiones mensuales
--              por rango de fechas para el año 2026 de la tabla `orders`
--              (orders_2026_01 a orders_2026_04), optimizando el rendimiento
--              y mantenimiento de grandes volúmenes de pedidos históricos.
-- ============================================================================

CREATE TABLE IF NOT EXISTS orders_2025_01 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE IF NOT EXISTS orders_2025_02 PARTITION OF orders
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE IF NOT EXISTS orders_2025_03 PARTITION OF orders
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE IF NOT EXISTS orders_2025_04 PARTITION OF orders
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

CREATE TABLE IF NOT EXISTS orders_2025_05 PARTITION OF orders
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE IF NOT EXISTS orders_2025_06 PARTITION OF orders
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE IF NOT EXISTS orders_2025_07 PARTITION OF orders
    FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE IF NOT EXISTS orders_2025_08 PARTITION OF orders
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE IF NOT EXISTS orders_2025_09 PARTITION OF orders
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE IF NOT EXISTS orders_2025_10 PARTITION OF orders
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE IF NOT EXISTS orders_2025_11 PARTITION OF orders
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE IF NOT EXISTS orders_2025_12 PARTITION OF orders
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

CREATE TABLE IF NOT EXISTS orders_default PARTITION OF orders DEFAULT;