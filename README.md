<h1 align="center">Guía de Actividad U2: PostgreSQL - Diseño Relacional Avanzado</h1>

<div align="center">
    <img src="https://img.shields.io/badge/SQL-Orange?style=for-the-badge&logo=sql&logoColor=white" alt="SQL Badge" />
    <img src="https://img.shields.io/badge/Universidad-La_Sabana-0033A0?style=for-the-badge" alt="UNISABANA Badge" />
    <img src="https://img.shields.io/badge/Maestría-Arquitectura_de_Software-2b9348?style=for-the-badge" alt="Maestria Badge" />
    <img src="https://img.shields.io/badge/Asignatura-Diseño_y_Optimización_de_Bases_de_Datos-8A2BE2?style=for-the-badge" alt="Asignatura Badge" />
    <img src="https://img.shields.io/badge/Status-Completado-success?style=for-the-badge" alt="Status Badge" />
</div>

<p align="center">
    <i>Archivo correspondiente a las Actividades Evaluativas de la Unidad 2.</i>
</p>

---

## Tabla de Contenidos

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Arquitectura Híbrida](#arquitectura-híbrida)
3. [Registros de Decisiones Arquitectónicas (ADR)](#registros-de-decisiones-arquitectónicas-adr)
4. [Estructura del Repositorio](#estructura-del-repositorio)
5. [Tecnologías](#tecnologías)
6. [Decisiones Arquitectónicas](#decisiones-arquitectónicas)
7. [Uso y Configuración](#uso-y-configuración)
8. [Autores](#autores)

---

## Descripción del Proyecto

Este repositorio contiene el diseño conceptual, lógico e implementación práctica de la base de datos para **Ecommify**, una plataforma de comercio electrónico multivendedor de productos tecnológicos.

El proyecto implementa una **arquitectura híbrida** (Persistencia Políglota) capaz de soportar:

- **Cargas Transaccionales (OLTP)**: Órdenes, pagos e inventario con garantías ACID
- **Cargas Analíticas (OLAP)**: Reportes y dashboards de desempeño
- **Alta Disponibilidad**: Catálogos extensos y búsquedas en tiempo real

### Módulos Principales

| Módulo | Motor | Propósito |
|--------|-------|----------|
| **Transaccional** | PostgreSQL | Órdenes, pagos e inventario con integridad garantizada |
| **Documental** | MongoDB | Catálogos, carritos y reviews con disponibilidad máxima |

---

## Arquitectura Híbrida

La arquitectura de Ecommify responde al **Teorema CAP**, eligiendo estrategias diferentes según el dominio de datos:

### PostgreSQL: Clasificación CP (Consistencia + Tolerancia)

**Prioridad:** Integridad transaccional sobre disponibilidad temporal

- ✅ Transacciones ACID completas
- ✅ Control de inventario sincronizado
- ✅ Pasarela de pagos segura
- ⚠️ Puede bloquear escrituras ante partición de red

**Aplicación:** Pagos, facturas, movimientos contables

### MongoDB: Clasificación AP (Disponibilidad + Tolerancia)

**Prioridad:** Respuesta inmediata sobre consistencia temporal

- ✅ Disponibilidad máxima (Replica Sets)
- ✅ Escalabilidad horizontal
- ✅ Consultas de catálogo <100ms
- ℹ️ Sincronización eventual tras estabilización

**Aplicación:** Catálogos, carritos, búsquedas, reviews

---

## Registros de Decisiones Arquitectónicas (ADR)

Los **ADR** (Architecture Decision Records) documentan las decisiones clave que fundamentan el diseño. Este proyecto incluye los siguientes ADR:

### ADR-1: Persistencia Políglota vs Motor Único

**Estado:** ✅ Aceptado

**Contexto:**
- Olist requiere operaciones transaccionales críticas (pagos, inventario)
- Simultáneamente, necesita catálogos extensos con consultas ágiles
- Un motor único no puede satisfacer ambas demandas eficientemente

**Decisión:**
Implementar arquitectura híbrida con dos motores de base de datos:
- **PostgreSQL**: Datos financieros y transaccionales (CP)
- **MongoDB**: Catálogos y datos de lectura frecuente (AP)

**Beneficios:**
- ✅ Consistencia ACID garantizada en operaciones críticas
- ✅ Disponibilidad máxima en catálogos (sin bloqueos)
- ✅ Escalabilidad independiente por dominio
- ✅ Optimización específica por patrón de acceso

**Riesgos:**
- ⚠️ Mayor complejidad operacional
- ⚠️ Consistencia eventual entre sistemas
- ⚠️ Overhead de sincronización

**Mitigación:**
- Sincronización mediante eventos (event sourcing)
- Monitoreo de consistencia
- Límites claros entre dominios

**Referencia:** 📄 [Análisis Completo CAP](docs/adr_cap_analysis.md)

---

### ADR-2: Teorema CAP - Estrategia por Dominio

**Estado:** ✅ Aceptado

**PostgreSQL → Clasificación CP**
| Aspecto | Decisión |
|---------|----------|
| **Prioridad** | Consistencia > Disponibilidad |
| **Ante partición** | Bloquea escrituras (rechaza solicitudes) |
| **Garantías** | ACID completas + Integridad referencial |
| **Aplicación** | Pagos, facturas, inventario |
| **SLA** | 99.95% uptime con degradación controlada |

**MongoDB → Clasificación AP**
| Aspecto | Decisión |
|---------|----------|
| **Prioridad** | Disponibilidad > Consistencia temporal |
| **Ante partición** | Responde inmediatamente (eventual consistency) |
| **Garantías** | Sincronización eventual, tolerancia a fallos |
| **Aplicación** | Catálogos, carritos, búsquedas, reviews |
| **SLA** | 99.99% uptime |

---

### ADR-3: Tipos Nativos Especializados (JSONB)

**Estado:** ✅ Aceptado

**Problema:**
Los atributos de productos son altamente heterogéneos:
- Sofás: dimensiones, tapicería, color, peso
- Computadores: RAM, CPU, SSD, display
- Celulares: pantalla, cámara, batería, 5G

**Solución:**
Usar **JSONB en PostgreSQL** en lugar de normalización extrema:

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    attributes JSONB NOT NULL,  -- Flexibilidad sin ALTER TABLE
    category_id INT REFERENCES categories(id)
);
```

**Beneficios:**
- ✅ Evita migraciones de esquema costosas
- ✅ Consultas rápidas con índices JSONB
- ✅ Búsqueda tipada con operadores nativos
- ✅ Mantiene integridad referencial

**Trade-offs:**
- ⚠️ Menor normalización (requiere validación en aplicación)
- ⚠️ Queries más complejas que SQL puro

---

### ADR-4: Escalabilidad OLTP/OLAP

**Estado:** ✅ Aceptado

**Estrategia 1: Particionamiento Range (hot/cold)**
```
Tabla: orders
├── orders_2024_q1  (HOT - índices activos)
├── orders_2024_q2  (WARM)
├── orders_2023_*   (COLD - menos frecuente)
└── orders_2022_*   (ARCHIVE - comprimido)
```
**Beneficio:** Mantiene índices ágiles, archiva datos fríos

**Estrategia 2: Vistas Materializadas**
```sql
CREATE MATERIALIZED VIEW sales_dashboard AS
SELECT
    DATE_TRUNC('day', order_date) as day,
    category,
    COUNT(*) as total_orders,
    SUM(total_amount) as revenue
FROM orders
GROUP BY DATE_TRUNC('day', order_date), category;

CREATE INDEX idx_sales_dashboard_day ON sales_dashboard(day);
```
**Beneficio:** Dashboards precalculados sin carga transaccional

**Estrategia 3: Réplicas de Lectura**
- Replicación física de PostgreSQL
- OLAP queries en replica (no afecta transacciones)
- Read scaling independiente

---

### ADR-5: Búsqueda Full-Text Optimizada

**Estado:** ✅ Aceptado

**Extensión:** `pg_trgm` (PostgreSQL Trigram)

**Caso de Uso:**
```sql
-- Búsqueda: "iphone 15"
SELECT * FROM products
WHERE name % 'iphone 15'      -- Similitud fuzzy
ORDER BY similarity(name, 'iphone 15') DESC;
```

**Índice:**
```sql
CREATE INDEX idx_products_name_trgm
ON products USING GIN (name gin_trgm_ops);
```

**Rendimiento:**
- Sin índice: 500ms (full table scan)
- Con índice: <50ms (trigram search)

---

## Estructura del Repositorio

```
Bases-de-Datos-U2/
├── README.md                                    # Este archivo
├── docs/                                        # Documentación y decisiones
│   ├── adr_cap_analysis.md                      # Análisis Detallado CAP & ADR
│   └── Extensiones_PostgreSQL_Ecommify.md       # Justificación de extensiones
├── postgresql/                                  # Módulo Relacional (OLTP/OLAP)
│   ├── docker-compose.yml                       # Contenedor PostgreSQL
│   ├── schema/                                  # Scripts DDL
│   │   ├── 00_extensions.sql                    # Extensiones (PostGIS, pg_trgm)
│   │   ├── 01_types.sql                         # Tipos personalizados
│   │   ├── 02_tables.sql                        # Tablas con JSONB
│   │   ├── 03_partitions.sql                    # Estrategia hot/cold
│   │   ├── 04_indexes.sql                       # Índices optimizados
│   │   ├── 05_triggers.sql                      # Reglas y triggers
│   │   └── 06_views_materialized.sql            # Vistas para OLAP
│   ├── seed_data/                               # Inicialización
│   │   └── 01_seed_sample_data.sql              # Datos de prueba
│   └── queries/                                 # Consultas especializadas
│       ├── 01_oltp_queries.sql                  # Transaccionales (10ms)
│       ├── 02_search_queries.sql                # Búsquedas full-text (<50ms)
│       └── 03_olap_queries.sql                  # Analíticas (~1s)
└── mongodb/                                     # Módulo NoSQL (Disponibilidad)
    ├── docker-compose.yml                       # Contenedor MongoDB 6.0
    ├── model_design.json                        # Esquema de documentos
    └── mongo-init.js                            # Inicialización de colecciones
```

---

## Tecnologías

### Bases de Datos

| Tecnología | Rol | Versión | Clasificación CAP |
|------------|-----|---------|------------------|
| **PostgreSQL** | OLTP/OLAP relacional | 14+ | CP (Consistencia) |
| **MongoDB** | NoSQL documental | 6.0+ | AP (Disponibilidad) |

### Extensiones PostgreSQL

| Extensión | Caso de Uso |
|-----------|-----------|
| **PostGIS** | Geolocalización (cálculo de costos de envío) |
| **pg_trgm** | Búsqueda full-text fuzzy (productos) |
| **JSONB** | Atributos heterogéneos de productos |
| **uuid-ossp** | Identificadores globales únicos |

### Orquestación

- **Docker & Docker Compose**: Contenedores reproducibles con configuración versionada
- **Git**: Control de versiones de esquemas y scripts

---

## Decisiones Arquitectónicas

### 1. Segregación por Dominio

**Problema:** Un motor no puede satisfacer demandas conflictivas

**Solución:**
- ✅ PostgreSQL para datos financieros críticos (CP)
- ✅ MongoDB para datos de acceso frecuente (AP)

### 2. Consistencia Eventual vs Inmediata

| Dominio | Estrategia | Motivación |
|---------|-----------|-----------|
| Pagos | Consistencia inmediata | Evitar doble gasto |
| Inventario | Consistencia inmediata | Evitar sobreventa |
| Catálogos | Consistencia eventual | Maximizar disponibilidad |
| Reviews | Consistencia eventual | Tolerancia a demora |

### 3. Escalabilidad

- **OLTP:** Particionamiento range + índices ágiles
- **OLAP:** Vistas materializadas + replicas de lectura
- **OLAP:** Transformación schedule (nightly)

---

## Uso y Configuración

### Prerrequisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- Bash (WSL en Windows)

### Iniciar Servicios

#### PostgreSQL

```bash
cd postgresql/
docker-compose up -d
docker-compose ps
```

#### MongoDB

```bash
cd mongodb/
docker-compose up -d
docker-compose ps
```

### Inicializar PostgreSQL

```bash
cd postgresql/

# Conectar
docker-compose exec postgres psql -U postgres -d ecommify

# En el cliente psql:
\i schema/00_extensions.sql
\i schema/01_types.sql
\i schema/02_tables.sql
\i schema/03_partitions.sql
\i schema/04_indexes.sql
\i schema/05_triggers.sql
\i schema/06_views_materialized.sql
\i seed_data/01_seed_sample_data.sql

\q
```

### Ejecutar Consultas

```bash
# OLTP (transaccional)
docker-compose exec postgres psql -U postgres -d ecommify \
  -f queries/01_oltp_queries.sql

# Búsqueda
docker-compose exec postgres psql -U postgres -d ecommify \
  -f queries/02_search_queries.sql

# OLAP (analítica)
docker-compose exec postgres psql -U postgres -d ecommify \
  -f queries/03_olap_queries.sql
```

---

## Documentación Adicional

- 📄 [Análisis Completo CAP & Decisiones Arquitectónicas](docs/adr_cap_analysis.md)
- 📄 [Extensiones PostgreSQL Especializadas](docs/Extensiones_PostgreSQL_Ecommify.md)

---

## Autores

Este proyecto fue desarrollado por el siguiente equipo académico:

<h3>Juan Daniel Valderrama Pérez</h3>

<h3>Jorge Esteban Triviño Correa</h3>

<h3>Javier Andres Baron Fontanilla</h3>

---

<div align="center">
    <p><strong>Universidad de La Sabana</strong> | Maestría en Arquitectura de Software</p>
    <p>Diseño y Optimización de Bases de Datos - Unidad 2</p>
</div>
