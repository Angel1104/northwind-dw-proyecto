# Diseño del modelo estrella — NorthWind

**Responsable:** Angel Christian Flores Lazarte

## Punto de partida: entender el negocio

NorthWind es una empresa que vende productos de alimentación a clientes
internacionales, a través de empleados que gestionan las órdenes y
transportistas que las envían. Las entidades centrales del negocio son:

- **Personas**: `Customers` (clientes), `Employees` (empleados).
- **Cosas**: `Products` (productos), agrupados en `Categories` y provistos
  por `Suppliers`; `Shippers` (transportistas).
- **El evento central del negocio**: una **orden de venta** (`Orders` +
  `OrderDetails`), que es la interacción que genera el dato que realmente le
  interesa analizar a la gerencia — cuánto se vendió, a quién, de qué, y
  cuándo.

Ese evento central es, por definición, el candidato natural a convertirse en
la tabla de **hechos** del warehouse: es una medida numérica (cantidad,
precio, descuento) que ocurre repetidamente en el tiempo, a diferencia de
las entidades que lo rodean, que son relativamente estables y descriptivas.

## Tabla de hechos: `FactSales`

Fusiona `Orders` + `OrderDetails` del OLTP: cada fila representa una línea
de detalle de una orden (un producto dentro de un pedido), que es el nivel
de grano más detallado disponible en el negocio.

Conserva las tres fechas de negocio de la orden (`OrderDate`,
`RequiredDate`, `ShippedDate`), cada una con su propia llave hacia
`DimDate`, porque cada una responde una pregunta distinta: cuándo se pidió,
cuándo se esperaba, y cuándo realmente se envió (la diferencia entre estas
últimas dos es, de hecho, una métrica de desempeño logístico interesante de
analizar).

## Tablas de dimensión

| Tabla OLTP de origen | Dimensión | Transformación |
|---|---|---|
| `Customers` | `DimCustomer` | Se usa prácticamente tal cual: es un catálogo estable de clientes. |
| `Employees` | `DimEmployee` | Se omite la jerarquía `ReportsTo` (propia de un modelo OLTP de RR.HH.), que no aporta al análisis de ventas. |
| `Products` + `Categories` + `Suppliers` | `DimProduct` | Se fusionan las tres tablas en una sola: la categoría y el proveedor dejan de requerir un *join* y pasan a ser columnas del propio producto. |
| `Shippers` | `DimShipper` | Se usa tal cual. |
| *(no existe en el OLTP)* | `DimDate` | Se genera una dimensión de tiempo nueva, con una fila por cada fecha real de operación del negocio, para analizar ventas por día, mes, trimestre, semestre y año sin depender de funciones de fecha en cada consulta. |

## ¿Por qué esto reduce la complejidad de los reportes?

Una pregunta de negocio típica — *"ventas totales por categoría de producto
y país del proveedor, en 1997"* — necesita, en el esquema OLTP, unir cinco
tablas: `OrderDetails`, `Orders`, `Products`, `Categories` y `Suppliers`. En
el warehouse, la misma pregunta se responde uniendo únicamente `FactSales`
y `DimProduct`: dos tablas, porque la categoría y el proveedor ya viven
dentro de la dimensión de producto.

Esa reducción de *joins* es, en esencia, el propósito completo de
desnormalizar: cambiar un esquema optimizado para *escribir* datos
consistentes (OLTP) por uno optimizado para *leer* datos rápido (warehouse),
aceptando a cambio cierta redundancia (el nombre de la categoría se repite
en cada fila de `DimProduct` en vez de vivir una sola vez en `Categories`).

## Diagrama

Ver [`diagrama-estrella.md`](./diagrama-estrella.md).

## Pruebas de integridad

El diseño se valida con el script
[`pruebas-integridad.sql`](./pruebas-integridad.sql), que verifica, una vez
que `NorthWindOLTP` y `NorthWindDW` existan en el mismo servidor:

- Que la cantidad de dimensiones y de llaves foráneas coincide con el
  diseño descrito en este documento.
- Que no existan registros huérfanos en `FactSales` (líneas de venta que
  apunten a una dimensión inexistente).
- Que los conteos de filas entre el OLTP y el warehouse sean coherentes
  (por ejemplo, que `DimCustomer` tenga la misma cantidad de filas que
  `Customers`).
