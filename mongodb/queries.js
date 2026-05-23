db = db.getSiblingDB('ecommify_nosql');

/**
 * CONSULTA 1: Flujo Operacional de Visualización del Checkout
 * Recupera una orden completa con toda la información desnormalizada de sus ítems, 
 * pagos y calificaciones en una sola lectura de disco por ID.
 */
db.orders.find({ "order_id": "e481f51cbdc54678b7cc49136f2d6af7" }).pretty();

/**
 * CONSULTA 2: Pipeline de Agregación - Top 5 Categorías con Mayores Ventas y Mejor Calificación
 * Simula un reporte analítico que cruza los documentos embebidos de ítems y reviews, 
 * uniendo dinámicamente con el catálogo de productos.
 */
db.orders.aggregate([
  { $match: { "order_status": "delivered" } },
  { $unwind: "$items" },
  { 
    $lookup: {
      from: "products",
      localField: "items.product_id",
      foreignField: "product_id",
      as: "product_detail"
    }
  },
  { $unwind: "$product_detail" },
  { $unwind: { path: "$reviews", preserveNullAndEmptyArrays: true } },
  {
    $group: {
      "_id": "$product_detail.product_category_name",
      "total_voldo": { $sum: "$items.price" },
      "cantidad_vendida": { $sum: 1 },
      "calificacion_promedio": { $avg: "$reviews.review_score" }
    }
  },
  { $sort: { "total_voldo": -1 } },
  { $limit: 5 },
  {
    $project: {
      "categoria": "$_id",
      "ingresos_totales": { $round: ["$total_voldo", 2] },
      "unidades_despachadas": "$cantidad_vendida",
      "score_promedio_review": { $round: ["$calificacion_promedio", 1] },
      "_id": 0
    }
  }
]);

/**
 * CONSULTA 3: Búsqueda Geoespacial de Compradores
 * Encuentra todos los compradores ubicados en un radio de 5 kilómetros a la redonda 
 * de un centro logístico específico en São Paulo usando el índice 2dsphere.
 */
db.customers.find({
  "locations.coordinates": {
    $near: {
      $geometry: {
        "type": "Point",
        "coordinates": [-46.6392, -23.5456] // Longitud, Latitud base de la zona comercial
      },
      $maxDistance: 5000 // Distancia expresada en metros (5 KM)
    }
  }
}, { "customer_id": 1, "city": 1, "_id": 0 });