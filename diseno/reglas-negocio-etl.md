# Reglas de negocio del ETL — NorthWindETL

---

Documento de diseño que describe la arquitectura y las reglas de negocio de la
**carga incremental del Data Warehouse `NorthWindDW`**, tanto de las
**dimensiones** (`DimCustomer`, `DimProduct`, `DimEmployee`, `DimShipper`,
`DimDate`) como de la tabla de hechos `FactSales`.

## Arquitectura del flujo

La carga se implementa en los paquetes de `NorthWindETL` (Integration Services)
y sigue el patrón de carga incremental por `rowversion`. **El mismo patrón se
aplica a cada tabla**: cada dimensión y la tabla de hechos tienen su propio
stored procedure de captura de cambios y su propia entrada en `PackageConfig`.

El siguiente es el flujo de `FactSales`, el más completo, donde los lookups
resuelven las claves sustitutas de las cuatro dimensiones:

```
NorthWindOLTP
  → GetSalesChangesByRowVersion (stored procedure)
  → OLE DB Source (Load Sales)
  → Lookup Customer → Lookup Product → Lookup Employee → Lookup Shipper
      ├── Match Output    → Load Staging (auditoría)
      └── No Match Output → New Sales (FactSales)
```

Las dimensiones siguen el mismo esquema, con su stored procedure propio
(`GetCustomerChangesByRowVersion`, `GetProductChangesByRowVersion`,
`GetEmployeeChangesByRowVersion`, `GetShipperChangesByRowVersion`, etc.) y sin
la cadena de lookups, porque cada una se construye directamente desde su tabla
de origen.

Cada paquete registra la última versión procesada en
`PackageConfig.LastRowVersion` (una fila por tabla), de modo que solo se leen
los registros modificados desde la ejecución anterior. La primera carga parte
de `LastRowVersion = 0` y trae el histórico completo.

## Reglas de negocio

### 1. Resolución de claves sustitutas

Las claves de negocio del origen (`CustomerID`, `ProductID`, `EmployeeID`,
`ShipVia`) nunca se cargan en `FactSales`. Se traducen a `CustomerSK`,
`ProductSK`, `EmployeeSK` y `ShipperSK` mediante Lookups en cascada contra las
dimensiones correspondientes.

### 2. Registros sin coincidencia

Si una clave de negocio no existe en su dimensión, el registro se envía por la
salida *Lookup No Match Output* a la tabla de staging en lugar de insertarse en
`FactSales`. Esto evita violaciones de clave foránea y permite auditar los datos
huérfanos.

### 3. Cobertura de DimDate

`DimDate` debe cubrir todo el rango de fechas del origen: desde `1996-07-04`
hasta `1998-06-11`. Si el rango se queda corto, la carga falla por la FK
`FK_FactSales_DimDate_Required`.

### 4. Fechas desconocidas

Los `NULL` en `RequiredDate` y `ShippedDate` se resuelven con la fila de respaldo
`DateKey = 0` de `DimDate` (registro *Unknown*), de modo que la FK nunca recibe
un NULL. En los reportes, `DateKey = 0` se excluye o se trata como NULL.

### 5. Métricas calculadas vs. copiadas

Solo una columna se calcula en el flujo:

\[
TotalVenta = UnitPrice \times Quantity \times (1 - Discount)
\]

El resto de las métricas se copian sin transformación desde el OLTP:

| Columna | Origen | Tratamiento |
|---|---|---|
| `Quantity` | `Order Details` | Copia directa |
| `UnitPrice` | `Order Details` | Copia directa |
| `Discount` | `Order Details` | Copia directa |
| `Freight` | `Orders` | Copia + prorrateo (regla 6) |
| `TotalVenta` | — | Calculada en el flujo |

### 6. Prorrateo de Freight sin pérdida de centavos

`Freight` es un costo **a nivel de orden** (vive en `Orders`), pero `FactSales`
tiene granularidad de **línea**. Para no duplicar el costo, el flete de cada
orden se reparte entre sus líneas en proporción a su importe:

\[
Freight_{linea} = Freight_{orden} \times \frac{LineTotal_{linea}}{LineTotal_{orden}}
\]

donde \(LineTotal = UnitPrice \times Quantity \times (1 - Discount)\).

El prorrateo genera fracciones de centavo que, al redondear cada línea por
separado, no suman el flete original. Para evitarlo:

1. Todas las líneas se redondean a 2 decimales.
2. La **última línea de la orden** absorbe la diferencia:
   \[
   Freight_{ultima} = Freight_{orden} - \sum Freight_{lineas\ anteriores}
   \]
3. Si la orden tiene una sola línea, recibe el flete completo.

**Validación obligatoria** por cada `OrderID`:

\[
\sum Freight_{FactSales} = Freight_{Orders}
\]

Así la suma de los fletes prorrateados de todas las líneas de una orden es
exactamente igual al flete registrado en `Orders`, sin centavos perdidos ni
sobrantes.

### 7. Atributos de producto copiados del OLTP

`UnitsInStock`, `UnitsOnOrder`, `ReorderLevel` y `Discontinued` son atributos
**de producto**, no de la venta. Se cargan en `DimProduct` directamente desde
`Products` del OLTP, sin transformación, porque la base transaccional ya los
mantiene actualizados. No forman parte del flujo de `FactSales`: incluirlos en
el hecho los congelaría al momento de la venta y rompería el análisis de
inventario actual.

### 8. Grano de DimEmployee

`DimEmployee` tiene granularidad **empleado-territorio**: un empleado con varios
territorios genera una fila por cada uno (49 filas para 9 empleados),
conservando la relación completa de `EmployeeTerritories`. `EmployeeID` **no es
único** en la dimensión; la clave de negocio es `EmployeeID + TerritoryID` y el
MERGE debe matchear por ambos campos. En reportes, usar
`COUNT(DISTINCT EmployeeID)` para no duplicar empleados.

### 9. Uso de las claves de fecha

`OrderDateKey`, `RequiredDateKey` y `ShippedDateKey` son enteros en formato
`YYYYMMDD`. Para filtrar o agrupar por fecha se hace JOIN con `DimDate` por
`DateKey`, nunca conversión directa del entero.

## Scripts de inicialización

Los scripts de `SQL_Scripts/` se ejecutan una sola vez, antes de la primera
carga, y en este orden:

| Orden | Script | Propósito |
|---|---|---|
| 1 | `01_Populate_DimDate.sql` | Poblar `DimDate` (1996-07-04 a 1998-06-11) con Tally Table |
| 2 | `02_Insert_Unknown_DimDate.sql` | Insertar la fila `DateKey = 0` para fechas NULL |
| 3 | `03_Seed_PackageConfig.sql` | Sembrar `LastRowVersion = 0` por tabla |

## Cómo ejecutar

1. Desplegar `NorthWindOLTP` y `NorthWindDW` en la instancia de SQL Server.
2. Ejecutar los scripts de `SQL_Scripts/` en el orden indicado.
3. Abrir `NorthWindDW.sln` en Visual Studio con Integration Services y desplegar
   `NorthWindETL`.
4. Ejecutar los paquetes de carga. La primera ejecución parte de
   `LastRowVersion = 0` y trae el histórico completo: las dimensiones se pueblan
   con sus propios paquetes y `FactSales` queda con 2 155 líneas de hechos.
