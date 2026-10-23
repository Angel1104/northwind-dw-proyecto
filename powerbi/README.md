# NorthWind — Visualización en Power BI

Tarea 3.2 — Módulo II, Diplomado en Ciencia de Datos (UMSS)

Integrantes:

- Angel Christian Flores Lazarte
- Daniela Zapata Pari
- Kevin Omar Mamani Quispe

## Entrega

El reporte fue construido y verificado el 23/10/2026 con Power BI Desktop
2.159.883.0. La entrega incluye:

- `NorthWind-Visualizacion.pbix`: reporte funcional con datos importados.
- `NorthWind-Visualizacion.pbip`, `.Report` y `.SemanticModel`: versión fuente
  para mantenimiento en Git.
- `capturas/`: una imagen revisada de cada página.
- `generar-modelo-local.ps1` y `generar-reporte.ps1`: generación reproducible
  del modelo y del diseño PBIR.
- `cargar-datos-local.sql`: carga del DW desde el OLTP restaurado.
- `validacion.sql` y `validacion-modelo.dax`: controles independientes.

El trabajo está en `feature/powerbi-angel`, creada desde `main` en `6f7627e`.
No se modificó el trabajo OLTP, ETL u OLAP de los demás integrantes.

## Fuente realmente utilizada

No había una instancia SSAS de Kevin desplegada y accesible en esta PC. Se usó
la alternativa permitida por la consigna: **Import** desde SQL Server, base
`NorthWindDW`, cargando solo `FactSales` y las cinco dimensiones.

La fuente original es `NorthWind.bak`, incluida en el `NorthWind.zip` entregado
por el usuario. El backup se restauró localmente como `NorthWindOLTP` y luego se
cargó `NorthWindDW` con `cargar-datos-local.sql`. El motor local es SQL Server
2022 Developer en el contenedor Docker `northwind-sql2022`, publicado únicamente
en `127.0.0.1:1433`.

El proyecto Power BI usa:

- Servidor: `127.0.0.1`
- Base: `NorthWindDW`
- Modo: Import
- Tablas: `Customer`, `Date`, `Employee`, `Product`, `Shipper`, `FactSales`

La contraseña no se guarda en el repositorio. El PBIX conserva los datos
importados para la presentación; para actualizarlo en otra PC hay que restaurar
el backup, cargar el DW y configurar credenciales SQL locales.

## Requerimientos de negocio

| Solicitante simulado | Pregunta y decisión posible | Medidas y dimensiones | Página |
|---|---|---|---|
| Gerencia comercial | ¿Cómo evolucionan las ventas? Investigar caídas y priorizar seguimiento. | Ventas netas, pedidos, unidades, ticket; fecha de pedido | Resumen de ventas |
| Gestión de productos | ¿Qué categorías y productos concentran ventas? Priorizar surtido. | Ventas netas, unidades; categoría, producto | Productos y clientes |
| Gestión de clientes | ¿Qué clientes y países aportan más? Orientar seguimiento comercial. | Ventas netas, pedidos, ticket; cliente, país del cliente | Productos y clientes |
| Supervisión comercial | ¿Cómo se distribuyen ventas por empleado? Investigar diferencias de cartera. | Ventas netas, pedidos, ticket; empleado | Desempeño comercial |

## Modelo y medidas

El modelo tiene relaciones 1:* de cada dimensión hacia `FactSales`, con filtro
en una dirección. `OrderDateKey` es la relación activa de fecha; `RequiredDateKey`
y `ShippedDateKey` permanecen inactivas. `FullDate` es fecha, `MonthName` se
ordena por `MonthNumberOfYear` y `YearMonth` distingue correctamente año y mes.

Se crearon siete medidas:

- Ventas netas
- Unidades
- Pedidos
- Ticket promedio
- Ventas brutas
- Descuento monetario
- Descuento efectivo %

`TotalVenta` ya incluye el descuento. El ticket se calcula como ventas netas /
pedidos distintos, no como promedio de líneas. No se muestra símbolo monetario
porque la moneda del dataset no está confirmada.

## Páginas

1. **Inicio**: resumen ejecutivo, indicadores principales, integrantes y guía
   de las visualizaciones disponibles.
2. **Resumen de ventas**: cuatro tarjetas, evolución mensual, ventas por
   categoría y filtros de año/mes.
3. **Productos y clientes**: Top 10 dinámico de productos y clientes, detalle
   de clientes y filtros de año/mes/categoría/país.
4. **Desempeño comercial**: ventas e indicadores por empleado, ventas por país
   del cliente y filtros de año/mes.

## Verificación realizada

El PBIX se guardó, cerró, volvió a abrir y se consultó directamente en su motor
tabular. El PBIP también pasó la validación estructural con 0 errores y 0
advertencias. Las cuatro páginas se renderizaron con datos y se guardaron en
`capturas/`.

| Control | SQL Server | Power BI | Resultado |
|---|---:|---:|---|
| Ventas netas | 1.265.793,0394 | 1.265.793,0394 | Coincide |
| Unidades | 51.317 | 51.317 | Coincide |
| Pedidos distintos | 830 | 830 | Coincide |
| Ticket promedio | 1.525,0519 | 1.525,0519 | Coincide |
| Año 1997 — ventas | 617.085,2042 | 617.085,2042 | Coincide |
| Año 1997 — pedidos | 408 | 408 | Coincide |
| Beverages — ventas | 267.868,1805 | 267.868,1805 | Coincide |
| Beverages — pedidos | 354 | 354 | Coincide |

Conteos importados: 91 clientes, 709 fechas, 9 empleados, 77 productos, 3
transportistas y 2.155 líneas de venta. No existen duplicados en el grano
`(OrderID, ProductID)`.

## Hallazgos para la toma de decisiones

- **Período completo 1996–1998:** Beverages es la categoría con mayor venta,
  267.868,18 en 354 pedidos (21,16 % del total). Decisión posible: priorizar su
  disponibilidad y analizar qué productos explican esa concentración.
- **Período completo 1996–1998:** QUICK-Stop es el cliente con mayor venta,
  110.277,31 en 28 pedidos. Decisión posible: darle seguimiento comercial y
  revisar el riesgo de concentración junto con Ernst Handel y Save-a-lot.
- **Período completo 1996–1998:** Margaret Peacock concentra 232.890,85 en 156
  pedidos, el mayor monto entre empleados. Decisión posible: revisar su mezcla
  de clientes/productos como referencia, sin inferir causalidad ni productividad
  individual únicamente por ventas.

El año 1998 termina el 6 de mayo y es parcial; por eso su caída final no debe
interpretarse como deterioro anual.

## Actualización local

1. Iniciar Docker Desktop y el contenedor `northwind-sql2022`.
2. Comprobar que `NorthWindOLTP` y `NorthWindDW` existen.
3. Si el DW debe regenerarse, ejecutar `cargar-datos-local.sql` sobre la
   instancia local después de restaurar `NorthWind.bak`.
4. Abrir `NorthWind-Visualizacion.pbix`, configurar autenticación de base de
   datos para `127.0.0.1;NorthWindDW` y seleccionar **Actualizar**.
5. Ejecutar `validacion.sql` y contrastar los resultados anteriores.

No publicar en Power BI Service ni versionar credenciales o archivos locales
de caché `.pbi`.
