<h1 align="center">Guía de Actividad U2: PostgreSQL - Diseño Relacional Avanzado</h1>

<div align="center">
  <img src="https://img.shields.io/badge/SQL-Orange?style=for-the-badge&logo=sql&logoColor=white" alt="SQL Badge"/>
  <img src="https://img.shields.io/badge/Universidad-La_Sabana-0033A0?style=for-the-badge" alt="UNISABANA Badge"/>
  <img src="https://img.shields.io/badge/Maestr%C3%ADa-Arquitectura_de_Software-2b9348?style=for-the-badge" alt="Maestria Badge"/>
  <img src="https://img.shields.io/badge/Asignatura-Dise%C3%B1o%20y%20Optimizaci%C3%B3n%20de%20Bases%20de%20Datos-8A2BE2?style=for-the-badge" alt="Asignatura Badge"/>
  <img src="https://img.shields.io/badge/Status-Completado-success?style=for-the-badge" alt="Status Badge"/>
</div>

<p align="center">
  <i>Archivo correspondiente a las Actividades Formativas de la Unidad 2. Actividad de Investigación y Aplicación.</i>
</p>

---

### 📋 Índice

- [Sobre el Proyecto](#sobre-el-proyecto)
- [1. PostGIS](#1-postgis---datos-geoespaciales)
- [2. pg_trgm](#2-pg_trgm---búsqueda-de-texto-tolerante-a-errores)
- [3. pgcrypto](#3-pgcrypto---criptografía-avanzada)
- [Matriz de Decisión Final](#4-matriz-de-decisión-final)


---

# Sobre el Proyecto

Este documento detalla la justificación técnica, casos de uso estratégicos y viabilidad de la implementación de extensiones nativas de PostgreSQL en el ecosistema híbrido de Ecommify.

---

## 1. PostGIS - Datos Geoespaciales
* **Justificación:** Olist provee un dataset de geolocalización robusto (`olist_geolocation_dataset`). Calcular distancias de manera euclidiana plana genera errores logísticos severos debido a la curvatura terrestre.
* **Caso de Uso en Ecommify:** Optimización dinámica del costo de envío. Al procesar una orden, PostGIS calcula en milisegundos la distancia exacta sobre la esfera terrestre entre las coordenadas del vendedor (`seller_id`) y el cliente (`customer_id`).

* **Ejemplo de Consulta:**
```sql
SELECT s.seller_id, 
       ST_DistanceSphere(g_seller.geom, g_customer.geom) / 1000 AS distancia_km
FROM sellers s
JOIN geolocation g_seller ON s.seller_zip_code_prefix = g_seller.zip_code_prefix
JOIN customers c ON c.customer_id = :current_customer_id
JOIN geolocation g_customer ON c.customer_zip_code_prefix = g_customer.zip_code_prefix;
```
---

## 2. pg_trgm - Búsqueda de Texto Tolerante a Errores
* **Justificación:** Los usuarios de plataformas multivendedor suelen cometer errores ortográficos o tipográficos al buscar productos tecnológicos complejos (ej: "Smarthphone", "Samsun", "Laptor").

* **Caso de Uso en Ecommify:** Motor de búsqueda del catálogo web de alta tolerancia. Rompe los strings en trigramas para calcular la similitud semántica sin necesidad de configurar una infraestructura externa pesada como Elasticsearch en fases tempranas.

* **Ejemplo de Consulta:**

```sql
-- Creación del índice para acelerar búsquedas
CREATE INDEX idx_products_search_trgm ON products_advanced USING gin (product_category_name gin_trgm_ops);

-- Consulta de búsqueda con umbral de similitud
SELECT product_id, product_category_name, similarity(product_category_name, 'tecnolgia') AS score
FROM products_advanced
WHERE product_category_name % 'tecnolgia'
ORDER BY score DESC;
```

---


## 3. pgcrypto - Criptografía Avanzada

* **Justificación:** Almacenar datos confidenciales, como tokens de plataformas de pago aliadas, contraseñas de vendedores o datos sensibles de clientes, en texto plano viola regulaciones estándar de la industria de comercio electrónico.

* **Caso de Uso en Ecommify:** Cifrado a nivel de fila y hashing seguro directamente en la base de datos sin sobrecargar la capa de aplicación.

* **Ejemplo de Consulta:** 
```sql
-- Inserción con hash robusto - Blowfish
UPDATE sellers 
SET security_token = crypt('token_secreto_pasarela', gen_salt('bf'))
WHERE seller_id = :seller_id;
```