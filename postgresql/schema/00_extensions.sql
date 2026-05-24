-- ============================================================================
-- MAESTRÍA EN ARQUITECTURA DE SOFTWARE
-- DISEÑO Y OPTIMIZACIÓN DE BASES DE DATOS
--
-- ARCHIVO: 00_extensions.sql
-- MÓDULO: Módulo Relacional - Esquema (PostgreSQL)
-- DESCRIPCIÓN: Habilitación de extensiones necesarias para Ecommify:
--              * pgcrypto: Generación segura de llaves primarias basadas en UUID.
--              * pg_trgm: Operaciones de coincidencia difusa basadas en trigramas.
--              * postgis: Soporte y almacenamiento de datos geográficos (coordenadas).
--              * hstore: Almacenamiento de pares clave-valor para atributos dinámicos.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS hstore;