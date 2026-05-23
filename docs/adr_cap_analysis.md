# Análisis de Persistencia Políglota, Teorema CAP y Decisiones Arquitectónicas - Ecommify

Diseño de persistencia de datos híbrida para Ecommify basado en análisis del ecosistema Olist.

---

## Glosario Técnico

- **ACID**: Atomicidad, Consistencia, Aislamiento, Durabilidad
- **CAP**: Consistencia, Disponibilidad, Tolerancia a Particiones
- **CP/AP**: Clasificaciones CAP (Consistencia+Tolerancia / Disponibilidad+Tolerancia)
- **Replica Sets**: Grupos de servidores MongoDB que sincronizan datos automáticamente
- **WiredTiger**: Motor de almacenamiento de MongoDB que comprime datos y optimiza acceso
- **2dsphere**: Índice geoespacial para búsquedas de proximidad
- **Consistencia Eventual**: Nodos sincronizados asíncronamente tras estabilización de red

---

## 1. Teorema CAP en Sistemas Distribuidos

El Teorema CAP postula que en cualquier sistema distribuido con particiones de red (P), se debe elegir entre:

- **Consistencia (C)**: Todos los nodos ven los mismos datos
- **Disponibilidad (A)**: El sistema responde siempre, incluso con datos desactualizados

**Ecommify elige dos estrategias según el dominio:**

### PostgreSQL: Clasificación CP (Consistencia + Tolerancia)

**Aplicación:** Módulo Financiero, Inventario y Pagos

- **Opción adoptada:** Prioriza consistencia sobre disponibilidad
- **Comportamiento ante partición:** Bloquea escrituras temporalmente
- **Ejemplos de fallos prevenidos:** Doble gasto de tarjeta, sobregiros, venta sin stock
- **Justificación:** Integridad referencial y ACID son inviolables en operaciones contables

### MongoDB: Clasificación AP (Disponibilidad + Tolerancia)

**Aplicación:** Catálogo, Carrito y Búsquedas

- **Opción adoptada:** Prioriza disponibilidad sobre consistencia temporal
- **Comportamiento ante partición:** Nodos activos responden inmediatamente
- **Sincronización:** Consistencia eventual asíncrona tras estabilización
- **Justificación:** Interrupciones del catálogo bloquean conversiones y generan pérdidas de ingresos

---

## 2. Arquitectura de Persistencia Políglota

Ecommify requiere un motor transaccional para operaciones financieras y uno documental para catálogo y navegación. Esta estrategia responde a demandas conflictivas de consistencia y disponibilidad.

---

## 3. Matriz de Selección de Motor de Base de Datos

**Tabla 1: Selección Rápida por Dominio**

| Dominio | Volumen | Estructura | Motor | Razón Primaria |
|---------|---------|-----------|-------|-----------------|
| **Órdenes de Compra** | Millones | Jerárquico anidado | MongoDB | Lecturas atómicas sin JOINs |
| **Catálogo de Productos** | Alto | Semiestructurado | MongoDB | Schema-less, atributos dinámicos |
| **Pagos y Facturación** | Moderado | Relacional estricto | PostgreSQL | Garantías ACID |
| **Logs y Auditoría** | Masivo | Desestructurado | MongoDB | Inserción rápida en ráfaga |
| **Geolocalización** | Millones | Geoespacial | MongoDB | Índice 2dsphere nativo |

### Justificación Técnica Detallada

**Órdenes de Compra (MongoDB)**
Embediendo ítems, pagos y calificaciones en un único documento, WiredTiger ejecuta lecturas atómicas de una pasada por disco, eliminando JOINs ineficientes del modelo SQL clásico.

**Catálogo de Productos (MongoDB)**
Los productos varían dinámicamente de atributos según categoría (sofá vs computador). La flexibilidad schema-less evita costosas migraciones de esquemas y sentencias ALTER TABLE complejas.

**Pasarela de Pagos (PostgreSQL)**
Garantiza cumplimiento irrestricto de reglas ACID. Los estados financieros deben mantenerse idénticos y consolidados en todo momento durante transacciones de negocio.

**Logs de Auditoría (MongoDB)**
El procesamiento de strings largos y comentarios variables se beneficia de la flexibilidad documental. Índices Multi-key permiten búsquedas de analítica de sentimientos sin degradar la base transaccional PostgreSQL.

**Geolocalización (MongoDB)**
La indexación nativa 2dsphere y operadores como $near resuelven cálculos de costos de envío por proximidad en microsegundos, sin recurrir a trigonometría en backend.

---

## 4. Conclusiones Arquitectónicas

1. **Desacoplamiento de Catálogo**
   - Reduce carga del pool de conexiones PostgreSQL en ~50% bajo picos de tráfico
   - Protege operaciones financieras de caídas por saturación
   - Permite escala horizontal independiente del motor transaccional

2. **Desnormalización de Datos de Vendedor**
   - Costo: ~150MB almacenamiento adicional en MongoDB
   - Beneficio: Reducción de ~200ms a <50ms en renderizado de tarjetas de producto
   - ROI positivo si >100M visitas/mes

3. **Beneficios Operacionales**
   - Consistencia eventual en catálogo vs consistencia inmediata en finanzas
   - Latencia de lectura <100ms en navegación esperada
   - Integridad transaccional garantizada en movimientos contables