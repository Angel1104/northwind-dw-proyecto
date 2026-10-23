# Informe de implementación — Tarea 3.2 Power BI

## 1. Información general

- Institución: Posgrado FCyT — Universidad Mayor de San Simón.
- Módulo: Diplomado en Ciencia de Datos, Módulo II.
- Tarea: 3.2 — Visualización de Datos.
- Fecha de elaboración y validación: 23/10/2026.
- Rama de trabajo: `feature/powerbi-angel`.
- Base de la rama: `main`, commit `6f7627e`.
- Pull request: <https://github.com/Angel1104/northwind-dw-proyecto/pull/7>.

Integrantes:

- Angel Christian Flores Lazarte.
- Daniela Zapata Pari.
- Kevin Omar Mamani Quispe.

## 2. Requerimientos cubiertos

La implementación responde a los cuatro puntos de la consigna:

1. Utilizar como fuente la base creada y poblada en el proceso ETL.
2. Elaborar el modelo de datos de Power BI con métricas de negocio.
3. Elaborar visualizaciones orientadas a requerimientos del negocio.
4. Incorporar una página de inicio que resuma las visualizaciones disponibles.

El repositorio también identifica a todos los integrantes y contiene los
artefactos necesarios para usar, revisar y defender el trabajo.

## 3. Preparación del entorno y los datos

Se comprobó el estado del repositorio antes de modificarlo y se trabajó desde
una rama nueva creada directamente desde `main`. Se instalaron o prepararon:

- Power BI Desktop 2.159.883.0.
- SQL Server Management Studio 20.2.
- `sqlcmd` y `SqlPackage`.
- SQL Server 2022 Developer mediante Docker Desktop.

El archivo `NorthWind.zip` proporcionado para la tarea contiene
`NorthWind.bak`. El backup se restauró como `NorthWindOLTP` y se utilizó para
poblar `NorthWindDW` mediante `cargar-datos-local.sql`. El servidor local se
publicó únicamente en `127.0.0.1:1433`.

Conteos cargados en el DW:

| Tabla | Filas |
|---|---:|
| DimCustomer | 91 |
| DimDate | 709 |
| DimEmployee | 9 |
| DimProduct | 77 |
| DimShipper | 3 |
| FactSales | 2.155 |

## 4. Modelo semántico

El reporte usa modo **Import** desde `NorthWindDW`. Se cargaron exclusivamente
las cinco dimensiones y la tabla de hechos, sin tablas de staging ni vistas
agregadas.

Las tablas se presentan al usuario como:

- `Customer`
- `Date`
- `Employee`
- `Product`
- `Shipper`
- `FactSales`

Las dimensiones tienen relaciones 1:* hacia `FactSales`, con dirección de
filtro única. La relación de `OrderDateKey` está activa y las relaciones de
`RequiredDateKey` y `ShippedDateKey` están inactivas. `FullDate` está tipada
como fecha, `MonthName` se ordena mediante `MonthNumberOfYear` y `YearMonth`
permite representar correctamente la tendencia entre años.

## 5. Métricas de negocio

Se implementaron siete medidas DAX:

- `Ventas netas`
- `Unidades`
- `Pedidos`
- `Ticket promedio`
- `Ventas brutas`
- `Descuento monetario`
- `Descuento efectivo %`

`Ventas netas` utiliza `TotalVenta`, que ya contiene cantidad, precio histórico
y descuento. `Pedidos` cuenta órdenes distintas y `Ticket promedio` se calcula
como ventas netas divididas entre pedidos, evitando el promedio incorrecto por
línea de pedido.

## 6. Diseño del reporte

El archivo final contiene cuatro páginas y 35 visuales:

### Inicio

Presenta los integrantes, los cuatro indicadores principales y una explicación
de las tres áreas analíticas disponibles. Las pestañas inferiores permiten
navegar por el informe.

### Resumen de ventas

Incluye ventas netas, unidades, pedidos, ticket promedio, evolución mensual y
ventas por categoría, con filtros de año y mes.

### Productos y clientes

Incluye Top 10 dinámico de productos, Top 10 dinámico de clientes, detalle de
clientes y filtros por año, mes, categoría y país.

### Desempeño comercial

Incluye ventas por empleado, ventas/pedidos/ticket por empleado y ventas por
país del cliente. El texto del reporte advierte que el período de 1998 está
incompleto.

## 7. Incidencias resueltas

Durante la carga apareció un reporte Frown de Power BI con
`NullReferenceException` en `AddCredentialsToConnectionString`. La excepción
se originó en una ruta temporal de credenciales OLE DB, no en las medidas ni en
los datos. Se eliminó esa ruta y se configuró el conector SQL Server nativo.

También se detectó que `localhost` podía resolverse por Named Pipes o IPv6,
mientras Docker estaba publicado en IPv4. El origen se cambió a `127.0.0.1`,
lo que permitió actualizar las seis tablas correctamente.

Finalmente se corrigió la codificación UTF-8 del generador para evitar textos
con acentos dañados en títulos como Evolución o Desempeño.

## 8. Validación

El PBIP pasó la validación estructural con 0 errores y 0 advertencias. El PBIX
se guardó, cerró y volvió a abrir; después de la reapertura se consultó su motor
tabular y se confirmaron los siguientes resultados:

| Control | SQL Server | Power BI | Resultado |
|---|---:|---:|---|
| Ventas netas | 1.265.793,0394 | 1.265.793,0394 | Coincide |
| Unidades | 51.317 | 51.317 | Coincide |
| Pedidos distintos | 830 | 830 | Coincide |
| Ticket promedio | 1.525,0519 | 1.525,0519 | Coincide |
| Ventas de 1997 | 617.085,2042 | 617.085,2042 | Coincide |
| Pedidos de 1997 | 408 | 408 | Coincide |
| Ventas de Beverages | 267.868,1805 | 267.868,1805 | Coincide |
| Pedidos de Beverages | 354 | 354 | Coincide |

No se encontraron duplicados en `(OrderID, ProductID)` ni claves huérfanas.
Las cuatro páginas se renderizaron y sus capturas se guardaron en `capturas/`.

## 9. Hallazgos de negocio

- En todo el período, Beverages lidera las ventas con 267.868,18 en 354
  pedidos, equivalente al 21,16 % del total. Se recomienda revisar inventario y
  los productos que explican esta concentración.
- QUICK-Stop es el cliente con mayor venta: 110.277,31 en 28 pedidos. Se puede
  priorizar el seguimiento comercial y revisar el riesgo de concentración.
- Margaret Peacock registra el mayor monto atribuido entre empleados:
  232.890,85 en 156 pedidos. La mezcla de clientes y productos puede analizarse
  como referencia, sin interpretar el monto como prueba aislada de productividad.

El último año es parcial: los datos de 1998 terminan el 6 de mayo. La caída del
último punto no debe interpretarse como deterioro anual.

## 10. Entregables

- `NorthWind-Visualizacion.pbix`: reporte funcional con los datos importados.
- `NorthWind-Visualizacion.pbip`: acceso al proyecto editable.
- `NorthWind-Visualizacion.Report/`: definición PBIR versionable.
- `NorthWind-Visualizacion.SemanticModel/`: modelo semántico versionable.
- `capturas/`: evidencia visual de las cuatro páginas.
- `README.md`: uso, fuente, medidas, verificación y hallazgos.
- `GUIA-CONSTRUCCION.md`: descripción reproducible del diseño.
- `cargar-datos-local.sql`: carga local del DW.
- `validacion.sql` y `validacion-modelo.dax`: controles independientes.
- `generar-modelo-local.ps1` y `generar-reporte.ps1`: generación reproducible.

La contraseña de SQL Server no se almacena en el repositorio. Para actualizar
el modelo en otra PC debe restaurarse la fuente, poblarse `NorthWindDW` y
configurarse la credencial local de Power BI.
