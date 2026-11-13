import sqlite3
import random
from datetime import datetime, timedelta
import pandas as pd

print("🚀 Iniciando reconstrucción con ordenamiento espejo estricto...")

# 1. Leemos el archivo original de la carpeta
archivo_origen = "datos_ecommerce_sucio.csv" 

try:
    df = pd.read_csv(archivo_origen)
    print(f"📊 Archivo cargado con {len(df)} filas originales.")

    # 2. Eliminamos los duplicados exactos (quedan 970 filas)
    df = df.drop_duplicates().reset_index(drop=True)

    # 3. Calculamos el Precio Total automáticamente
    df["Precio Total"] = df["Precio x Unidad"] * df["Unidades Vendidas"]

    # 4. ORDENAMIENTO ESTRICTO: Para evitar que los IDs repetidos se mezclen,
    # ordenamos por ID y desempatamos por Producto y Unidades Vendidas.
    df = df.sort_values(by=["ID", "Producto", "Unidades Vendidas"]).reset_index(drop=True)
    print("⚖️ Tabla ordenada con criterio estricto de desempate.")

    # 5. Agregamos las Formas de Pago y Fechas fijas sobre la tabla YA ORDENADA
    formas_pago = ["Tarjeta de Credito", "Tarjeta de Debito", "Transferencia", "Efectivo"]
    random.seed(42) # Bloquea la aleatoriedad para que sea idéntica siempre
    
    df["Forma de pago"] = [random.choice(formas_pago) for _ in range(len(df))]
    
    fecha_inicio = datetime(2026, 1, 1)
    df["Fecha"] = [(fecha_inicio + timedelta(days=random.randint(0, 310))).strftime("%Y-%m-%d") for _ in range(len(df))]
    print("📅 Fechas y Formas de pago inyectadas de forma consistente.")

    # 6. Clonación Directa: Guardamos la tabla exactamente en este orden en ambos lados
    conexion = sqlite3.connect("tienda.db")
    df.to_sql("ventas_consolidadas_final", conexion, if_exists="replace", index=False)
    conexion.close()

    df.to_excel("REPORTE_FINAL_LISTO.xlsx", index=False)

    print("\n✨ ¡CRUCE SEGURO COMPLETO! ✨")
    print("La tabla 'ventas_consolidadas_final' en SQL y el Excel 'REPORTE_FINAL_LISTO.xlsx'")
    print("son clones matemáticos exactos fila por fila.")

except Exception as e:
    print(f"\n❌ Detalle: {e}")