-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 01_types.sql
-- MÓDULO: Módulo Relacional - Esquema PostgreSQL
-- DESCRIPCIÓN: Definición de tipos de datos personalizados ENUMs,  para
--              controlar y validar el estado de los pedidos (order_status_type)
--              y los métodos de pago permitidos (payment_type) en Ecommify.
-- AUTORES: Juan Daniel Valderrama Pérez
--          Jorge Esteban Triviño Correa
--          Javier Andres Baron Fontanilla
-- ============================================================================

CREATE TYPE order_status_type AS ENUM (
    'CREATED',
    'APPROVED',
    'INVOICED',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED'
);

CREATE TYPE payment_type AS ENUM (
    'CREDIT_CARD',
    'DEBIT_CARD',
    'VOUCHER',
    'BOLETO',
    'PIX'
);