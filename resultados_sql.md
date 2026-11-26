# 📊 Resultados de Consultas SQL — Análisis de E-Commerce

A continuación se presentan las consultas ejecutadas sobre la base de datos **`tienda.db`** (tabla `ventas_reporte_definitivo`) junto con las tablas de salida obtenidas y su interpretación comercial.

---

### 1. Métricas Generales (KPIs Principales)

```sql
SELECT 
    COUNT(DISTINCT ID) AS total_transacciones,
    SUM("Unidades Vendidas") AS unidades_vendidas,
    ROUND(SUM("Precio Total"), 2) AS ingresos_totales,
    ROUND(AVG("Precio Total"), 2) AS ticket_promedio
FROM ventas_reporte_definitivo;
```

**Resultado:**

| total_transacciones | unidades_vendidas | ingresos_totales | ticket_promedio |
| :---: | :---: | :---: | :---: |
| 750 | 3,765 | $131,845.00 | $175.79 |

> **Insight:** Se registraron 750 operaciones válidas tras la limpieza de duplicados, con un ticket promedio de **$175.79**.

---

### 2. Ranking de Productos por Facturación

```sql
SELECT 
    Producto,
    SUM("Unidades Vendidas") AS total_unidades,
    ROUND(AVG("Precio x Unidad"), 2) AS precio_promedio,
    ROUND(SUM("Precio Total"), 2) AS facturacion_total
FROM ventas_reporte_definitivo
GROUP BY Producto
ORDER BY facturacion_total DESC;
```

**Resultado:**

| Producto | total_unidades | precio_promedio | facturacion_total |
| :--- | :---: | :---: | :---: |
| **Producto B** | 1,886 | $45.00 | **$84,870.00** |
| **Producto A** | 1,879 | $25.00 | **$46,975.00** |

> **Insight:** Ambos productos tienen un volumen de unidades casi idéntico (~1,880), pero el **Producto B genera el 64.4% de los ingresos** debido a su mayor precio unitario ($45 vs. $25).

---

### 3. Top Mercados por País y Región

```sql
SELECT 
    País,
    Región,
    COUNT(ID) AS cantidad_compras,
    ROUND(SUM("Precio Total"), 2) AS ingresos_totales
FROM ventas_reporte_definitivo
GROUP BY País, Región
ORDER BY ingresos_totales DESC
LIMIT 5;
```

**Resultado (Top 5):**

| País | Región | cantidad_compras | ingresos_totales |
| :--- | :--- | :---: | :---: |
| China | Asia | 88 | $16,445.00 |
| Estados Unidos | Norteamérica | 89 | $15,505.00 |
| Canadá | Norteamérica | 88 | $14,755.00 |
| Japón | Asia | 83 | $13,805.00 |
| México | LATAM | 63 | $11,780.00 |

---

### 4. Segmentación de Clientes (CTE + CASE WHEN)

```sql
WITH resumen_clientes AS (
    SELECT 
        Nombre,
        "Correo electrónico",
        COUNT(ID) AS frecuencia_compra,
        SUM("Precio Total") AS gasto_acumulado
    FROM ventas_reporte_definitivo
    GROUP BY "Correo electrónico", Nombre
)
SELECT 
    Nombre,
    "Correo electrónico",
    frecuencia_compra,
    ROUND(gasto_acumulado, 2) AS gasto_acumulado,
    CASE 
        WHEN gasto_acumulado >= 1000 THEN 'VIP'
        WHEN gasto_acumulado >= 500 THEN 'Frecuente'
        ELSE 'Ocasional'
    END AS segmento
FROM resumen_clientes
ORDER BY gasto_acumulado DESC;
```

> **Resultado:** Se identificaron **24 perfiles de clientes únicos**, clasificándolos automáticamente en segmentos **VIP** ($\ge\$1,000$), **Frecuente** ($\ge\$500$) y **Ocasional** para orientar campañas de fidelización.
