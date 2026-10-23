# Contexto para continuar este trabajo en otro chat

Copiar desde la sección siguiente y pegarla en el otro chat.

---

Estoy trabajando en la Tarea 3.2 de Visualización de Datos del Diplomado en
Ciencia de Datos de la UMSS. El repositorio es:

`https://github.com/Angel1104/northwind-dw-proyecto`

La implementación está en la rama `feature/powerbi-angel`, creada desde
`main` en el commit `6f7627e`. Revisa primero el PR abierto desde esa rama y no
reconstruyas el reporte desde cero.

## Consigna cubierta

- Usar como fuente la base creada y poblada por el proceso ETL.
- Crear el modelo de datos de Power BI con métricas de negocio.
- Crear visualizaciones según los requerimientos del negocio.
- Crear una página de inicio que resuma las visualizaciones disponibles.
- Mantener en el repositorio la evidencia y los integrantes del grupo.

Integrantes:

- Angel Christian Flores Lazarte.
- Daniela Zapata Pari.
- Kevin Omar Mamani Quispe.

## Estado terminado

- Power BI Desktop 2.159.883.0 instalado.
- SQL Server 2022 Developer ejecutándose en Docker para desarrollo local.
- El `NorthWind.bak` de `NorthWind.zip` fue restaurado como `NorthWindOLTP`.
- `NorthWindDW` fue poblado desde ese OLTP.
- La fuente Power BI es `127.0.0.1;NorthWindDW`, modo Import.
- Modelo estrella con `Customer`, `Date`, `Employee`, `Product`, `Shipper` y
  `FactSales`.
- Siete medidas DAX: ventas netas, unidades, pedidos, ticket promedio, ventas
  brutas, descuento monetario y descuento efectivo.
- Reporte con cuatro páginas: Inicio, Resumen de ventas, Productos y clientes,
  y Desempeño comercial.
- 35 visuales y capturas de las cuatro páginas.
- PBIX guardado, cerrado y reabierto correctamente.
- PBIP validado con 0 errores y 0 advertencias.

## Resultados de control

- Ventas netas: 1.265.793,0394.
- Unidades: 51.317.
- Pedidos distintos: 830.
- Ticket promedio: 1.525,0519.
- FactSales: 2.155 filas.
- Año 1997: 617.085,2042 y 408 pedidos.
- Categoría Beverages: 267.868,1805 y 354 pedidos.
- Duplicados y claves huérfanas: 0.

## Archivos principales

- `powerbi/NorthWind-Visualizacion.pbix`
- `powerbi/NorthWind-Visualizacion.pbip`
- `powerbi/README.md`
- `powerbi/INFORME-IMPLEMENTACION.md`
- `powerbi/GUIA-CONSTRUCCION.md`
- `powerbi/capturas/`
- `powerbi/validacion.sql`
- `powerbi/validacion-modelo.dax`

## Incidencias ya resueltas

El Frown de Power BI (`NullReferenceException` en
`AddCredentialsToConnectionString`) fue causado por credenciales en una ruta
OLE DB temporal. Se cambió al conector SQL Server nativo. Además, `localhost`
se reemplazó por `127.0.0.1` para evitar Named Pipes/IPv6 y se corrigió la
codificación UTF-8 de los textos.

## Cómo continuar

Lee `powerbi/README.md` e `powerbi/INFORME-IMPLEMENTACION.md`, revisa el PR y
trabaja sobre `feature/powerbi-angel`. No modifiques el trabajo OLTP/ETL/OLAP de
los compañeros. No publiques en Power BI Service ni cambies credenciales. Si
se pide una corrección, conserva el PBIX y el PBIP sincronizados, ejecuta
`powerbi-report-author validate powerbi/NorthWind-Visualizacion.pbip` y vuelve
a abrir el PBIX para comprobar sus medidas.

---
