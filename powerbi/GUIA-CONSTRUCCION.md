# Guía de construcción — NorthWind en Power BI

## 1. Conectar y documentar la fuente

1. Abrir Power BI Desktop y seleccionar **Obtener datos**.
2. Probar primero **SQL Server Analysis Services database** con la instancia
   SSAS que confirme Kevin. No usar el nombre del servidor relacional del
   `.bim` como si fuera necesariamente una instancia SSAS.
3. Confirmar que el modelo está desplegado y procesado y que aparecen las
   tablas `Customer`, `Date`, `Employee`, `Product`, `Shipper` y `FactSales`.
4. Revisar las opciones disponibles en la versión instalada. Si Import está
   disponible y trae los objetos requeridos, preferirlo para facilitar la
   presentación en otra PC, como hizo el docente en clase 9. Registrar el modo
   realmente usado en `README.md`.
5. Si SSAS no está accesible, usar **SQL Server database**, base
   `NorthWindDW`, modo **Import**, y seleccionar únicamente `FactSales` y las
   cinco dimensiones `Dim*` listadas en el README.
6. No escribir servidor o credenciales por intuición. Usar autenticación
   Windows o las credenciales que entregue el propietario de la instancia.

## 2. Revisar el modelo

En Import desde SQL, comprobar estas relaciones 1:* con filtro en una sola
dirección desde dimensión a hechos:

| Dimensión | Clave | Hechos | Estado |
|---|---|---|---|
| DimCustomer | CustomerSK | FactSales[CustomerSK] | Activa |
| DimProduct | ProductSK | FactSales[ProductSK] | Activa |
| DimEmployee | EmployeeSK | FactSales[EmployeeSK] | Activa |
| DimShipper | ShipperSK | FactSales[ShipperSK] | Activa |
| DimDate | DateKey | FactSales[OrderDateKey] | Activa |
| DimDate | DateKey | FactSales[RequiredDateKey] | Inactiva |
| DimDate | DateKey | FactSales[ShippedDateKey] | Inactiva |

Después:

1. Confirmar que `FullDate` es fecha. En el `.bim` revisado está como texto;
   si se usa Live, solicitar a Kevin que lo corrija en el modelo central.
2. Excluir `DateKey = 0` de visualizaciones de actividad, sin excluir hechos
   solo porque la fecha de envío sea desconocida.
3. Ordenar `MonthName` por `MonthNumberOfYear`.
4. En Import, crear la columna `AñoMes` incluida en `medidas.dax` y marcar
   `DimDate` como tabla de fechas usando `FullDate` después de comprobar que es
   continua y única.
5. Crear las siete medidas de `medidas.dax`; reutilizar cualquier medida
   central equivalente si Kevin la agrega posteriormente.
6. Ocultar en la vista de informe las claves técnicas, no borrarlas.

## 3. Formato común

- Lienzo 16:9, fondo `#F7F9FC`, tarjetas blancas y títulos en `#17324D`.
- Usar el tema `tema-northwind.json`.
- Títulos en español, tipografía legible, máximo dos decimales en importes.
- No aplicar símbolo monetario hasta confirmar la moneda.
- Segmentadores: Año y Mes en todas las páginas; Categoría y País donde
  aporten contexto.
- Sin mapas, visuales externos ni elementos puramente decorativos.

## 4. Página de inicio

Antes de las páginas analíticas se incluye **Inicio**, con los integrantes, los
cuatro indicadores principales y un resumen de las visualizaciones disponibles.
Las pestañas inferiores permiten acceder a cada sección del informe.

## 5. Página 1 — Resumen de ventas

Propósito: entender la evolución y el aporte por categoría.

| Visual | Campo o medida | Configuración |
|---|---|---|
| Tarjeta | Ventas netas | Dos decimales |
| Tarjeta | Unidades | Entero |
| Tarjeta | Pedidos | Entero |
| Tarjeta | Ticket promedio | Dos decimales |
| Línea | AñoMes / Ventas netas | Eje ascendente y continuo si aplica |
| Barras | CategoryName / Ventas netas | Descendente, etiquetas activas |

Añadir un texto breve: “El último período puede estar incompleto; comprobar
la fecha máxima antes de interpretar una caída”.

## 6. Página 2 — Productos y clientes

Propósito: detectar concentración de ventas y priorizar seguimiento comercial.

- Barras horizontales: `ProductName` y `Ventas netas`; filtro visual **Top N =
  10** por `[Ventas netas]`, luego **Aplicar filtro**.
- Barras horizontales: cliente `CompanyName` y `Ventas netas`; mismo Top 10.
- Tabla: `CompanyName`, `Country`, `[Ventas netas]`, `[Pedidos]`.
- Segmentadores: Año, Mes, Categoría y País del cliente.
- Título o tooltip del Top 10: “Top 10 dentro de los filtros actuales”. No
  presentar la suma del Top 10 como total global.

## 7. Página 3 — Desempeño comercial

Propósito: observar cómo se distribuye la actividad, sin inferir causalidad.

- Barras: empleado (`Employee[Full Name]` en OLAP, o FirstName + LastName en
  SQL) y `[Ventas netas]`.
- Tabla: empleado, `[Ventas netas]`, `[Pedidos]`, `[Ticket promedio]`.
- Barras: país del **cliente** y `[Ventas netas]`.
- Segmentadores: Año y Mes.
- Nota discreta: “Las diferencias reflejan actividad observada; no prueban por
  sí solas productividad ni causas”.

## 8. Interacciones y prueba

1. Usar **Formato > Editar interacciones** y comprobar que cada segmentador
   filtra los visuales pertinentes.
2. Al seleccionar una categoría, producto, cliente, empleado o país, los
   demás visuales deben cruzarse de forma comprensible. Desactivar solo las
   interacciones que produzcan ambigüedad.
3. Ejecutar `validacion.sql` y contrastar total, un año y una categoría.
4. Comprobar que pedidos es `DISTINCTCOUNT(OrderID)` y que el ticket es ventas
   dividido entre pedidos, no promedio de líneas.
5. Revisar la fecha máxima antes de describir caídas en el último período.
6. Abrir cada página, comprobar títulos, ejes y visuales sin errores; guardar,
   cerrar y volver a abrir.
7. Guardar como `powerbi/NorthWind-Visualizacion.pbix` y exportar una captura
   de cada página a esta carpeta.
8. Completar el README con conexión, actualización, resultados numéricos,
   limitaciones y tres hallazgos reales (período/filtro + cifra + decisión).

