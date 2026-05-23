db = db.getSiblingDB('ecommify_nosql');

db.customers.drop();
db.products.drop();
db.orders.drop();

db.createCollection('customers');
db.createCollection('products');
db.createCollection('orders');

// Índices de alta eficiencia para Customers
db.customers.createIndex({ "customer_id": 1 }, { unique: true, name: "idx_unique_customer_id" });
db.customers.createIndex({ "locations.coordinates": "2dsphere" }, { name: "idx_spatial_geo" });

// Índices para Products
db.products.createIndex({ "product_id": 1 }, { unique: true, name: "idx_unique_product_id" });
db.products.createIndex({ "product_category_name": 1 }, { name: "idx_category" });

// Índices compuestos y Multi-key para Orders (Optimización del Checkout)
db.orders.createIndex({ "order_id": 1 }, { unique: true, name: "idx_unique_order_id" });
db.orders.createIndex({ "customer_id": 1 }, { name: "idx_customer_orders" });
db.orders.createIndex({ "order_status": 1, "timeline.order_purchase_timestamp": -1 }, { name: "idx_status_date_compound" });
db.orders.createIndex({ "items.product_id": 1 }, { name: "idx_multikey_items_product" });

print("--> ¡La infraestructura e índices distribuidos de MongoDB para Ecommify han sido inicializados!");