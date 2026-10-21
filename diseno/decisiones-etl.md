# Decisiones de diseño — ETL NorthWind DW

## 1. Prorrateo del Freight (costo de flete)

**Problema:** En el OLTP, `Orders.Freight` es un valor por orden completa, pero
`FactSales` tiene una fila por línea de detalle (OrderID + ProductID). Hay que
decidir cómo representar el flete a nivel de línea.

**Opciones discutidas en clase (Clase 7, 12/10/2026):**

| Opción | Descripción | Ventaja | Desventaja |
|--------|-------------|---------|------------|
| A — Prorrateo | Dividir el flete entre las líneas de la orden | Cada fila tiene su porción del costo; los cálculos son directos | El criterio de prorrateo es una regla de negocio que debe documentarse |
| B — Repetición | Poner el flete completo en cada línea | No se inventa una regla de negocio | Hay que agrupar por OrderID antes de sumar para no inflar el total |

**Decisión:** Se eligió la **Opción A (prorrateo)**, dividiendo el flete de forma
equitativa entre la cantidad de líneas de cada orden (`Freight / COUNT(*) OVER
(PARTITION BY OrderID)`).

Se implementó un **método del residuo** para evitar pérdida por redondeo: la
última línea de cada orden (por orden de ProductID) absorbe la diferencia entre
la suma de los valores redondeados y el flete original redondeado. Esto
garantiza que `SUM(Freight)` agrupado por OrderID coincida exactamente con el
valor original de `Orders.Freight`.

**Justificación:** Para NorthWind, donde no hay datos de peso ni volumen por
producto, el prorrateo equitativo por línea es la opción más simple y
transparente. Un prorrateo por cantidad o por monto requeriría una regla de
negocio adicional que no está definida en el OLTP.

Ver: `NorthWindOLTP/Programmability/Stored Procedures/GetSalesChangesByRowVersion.sql`

## 2. Empleados con múltiples territorios

**Problema:** En NorthWind, un empleado puede estar asignado a múltiples
territorios (`EmployeeTerritories` es una tabla puente muchos-a-muchos). Pero
`DimEmployee` almacena un solo territorio por empleado.

**Decisión:** Se filtra con `ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY
TerritoryID)` y se conserva solo el primer territorio (por orden alfabético de
TerritoryID). Esto evita filas duplicadas en staging que corromperían el MERGE.

**Justificación:** El modelo dimensional prioriza la simplicidad de análisis. Para
reportes que necesiten la relación completa empleado-territorio, se consulta
directamente el OLTP.

Ver: `NorthWindOLTP/Programmability/Stored Procedures/GetEmployeeChangesByRowVersion.sql`

## 3. DateKey = 0 para fechas nulas

**Problema:** `Orders.ShippedDate` puede ser NULL (órdenes no enviadas). Pero
`FactSales.ShippedDateKey` es una FK a `DimDate.DateKey` y no admite NULL.

**Decisión:** Se usa `DateKey = 0` como valor sentinel que representa "fecha
desconocida / no aplica". En `DimDate`, la fila con `DateKey = 0` tiene
`FullDate = '1900-01-01'` y nombres marcados como `'N/A'` para que sea evidente
en reportes que no es una fecha real.

Ver: `SQL_Scripts/ScriptsDW/02_Patch_DimDate.sql`
