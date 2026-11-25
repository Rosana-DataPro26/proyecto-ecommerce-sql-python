-- ============================================================================
-- PROYECTO: Análisis de E-Commerce (SQL + Python)
-- BASE DE DATOS: tienda.db (SQLite)
-- TABLA PRINCIPAL: ventas_reporte_definitivo
-- DESCRIPCIÓN: Consultas de negocio para evaluar facturación, desempeño de
--              productos, mercados geográficos y segmentación de clientes.
-- ============================================================================

-- 1. MÉTRICAS GENERALES (KPIs PRINCIPALES)
-- Calcula ingresos totales, total de transacciones y ticket promedio.
SELECT 
    COUNT(DISTINCT ID) AS total_transacciones,
    SUM("Unidades Vendidas") AS unidades_vendidas,
    ROUND(SUM("Precio Total"), 2) AS ingresos_totales,
    ROUND(AVG("Precio Total"), 2) AS ticket_promedio
FROM ventas_reporte_definitivo;


-- 2. RANKING DE PRODUCTOS POR FACTURACIÓN
-- Identifica qué productos generan más ingresos y cuántas unidades se venden.
SELECT 
    Producto,
    SUM("Unidades Vendidas") AS total_unidades,
    ROUND(AVG("Precio x Unidad"), 2) AS precio_promedio,
    ROUND(SUM("Precio Total"), 2) AS facturacion_total
FROM ventas_reporte_definitivo
GROUP BY Producto
ORDER BY facturacion_total DESC;


-- 3. DESEMPEÑO GEOGRÁFICO (PAÍS Y REGIÓN)
-- Analiza qué mercados aportan mayor volumen de ventas.
SELECT 
    País,
    Región,
    COUNT(ID) AS cantidad_compras,
    ROUND(SUM("Precio Total"), 2) AS ingresos_totales
FROM ventas_reporte_definitivo
GROUP BY País, Región
ORDER BY ingresos_totales DESC;


-- 4. PREFERENCIAS DE FORMA DE PAGO
-- Calcula la participación porcentual de cada medio de pago.
SELECT 
    "Forma de pago",
    COUNT(ID) AS transacciones,
    ROUND(SUM("Precio Total"), 2) AS monto_total,
    ROUND(COUNT(ID) * 100.0 / (SELECT COUNT(*) FROM ventas_reporte_definitivo), 2) AS porcentaje_uso
FROM ventas_reporte_definitivo
GROUP BY "Forma de pago"
ORDER BY monto_total DESC;


-- 5. EVOLUCIÓN MENSUAL DE VENTAS
-- Muestra la tendencia de ingresos a lo largo del tiempo.
SELECT 
    STRFTIME('%Y-%m', Fecha_Real) AS mes,
    COUNT(ID) AS cantidad_ventas,
    ROUND(SUM("Precio Total"), 2) AS facturacion_mensual
FROM ventas_reporte_definitivo
GROUP BY mes
ORDER BY mes ASC;


-- 6. SEGMENTACIÓN DE CLIENTES (CTE + CASE WHEN)
-- Agrupa las compras por correo electrónico para identificar clientes recurrentes y VIP.
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