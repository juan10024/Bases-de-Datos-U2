-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 03_partitions.sql
-- MÓDULO: Módulo Relacional - Esquema (PostgreSQL)
-- DESCRIPCIÓN: Definición y creación física de las particiones mensuales
--              por rango de fechas para el año 2026 de la tabla `orders`
--              (orders_2026_01 a orders_2026_04), optimizando el rendimiento
--              y mantenimiento de grandes volúmenes de pedidos históricos.
-- AUTORES: Juan Daniel Valderrama Pérez
--          Jorge Esteban Triviño Correa
--          Javier Andres Baron Fontanilla
-- ============================================================================

CREATE TABLE orders_2026_01 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE orders_2026_02 PARTITION OF orders
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE orders_2026_03 PARTITION OF orders
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE orders_2026_04 PARTITION OF orders
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');