# NorthWind — Proyecto OLTP y Data Warehouse

Diplomado en Ciencia de Datos — UMSS FCyT
Módulo II — Almacenamiento y Preparación de Datos
Docente: M.Sc. Juan Marcelo Claure Salinas

## Integrantes del grupo

- Angel Christian Flores Lazarte ([Angel1104](https://github.com/Angel1104))
- Daniela Zapata Pari ([DanieZapata](https://github.com/DanieZapata))
- Kevin Omar Mamani Quispe ([kevdev21](https://github.com/kevdev21))

## Descripción

Este repositorio contiene dos proyectos de SQL Server (`.sqlproj`), creados
en Visual Studio a partir de la base de datos NorthWind entregada para el
proyecto final:

- **`NorthWindOLTP/`**: proyecto de SQL Server Database Project con el
  esquema transaccional (OLTP) original de NorthWind.
- **`NorthWindDW/`**: proyecto de SQL Server Database Project con el modelo
  dimensional (modelo estrella) derivado del OLTP, compuesto por una tabla
  de hechos y sus tablas de dimensión.
- **`NorthWindETL/`**: proyecto de Integration Services (SSIS) que carga el
  modelo dimensional desde el OLTP mediante procesos de carga incremental.

## Estructura del repositorio

```
diseno/
├── modelo-estrella.md       (justificación del diseño: Fact, Dim, por qué)
├── diagrama-estrella.md     (diagrama entidad-relación, Mermaid)
├── reglas-negocio-etl.md    (arquitectura del ETL + reglas de negocio)
└── pruebas-integridad.sql   (script de validación del modelo implementado)

NorthWindOLTP/
└── (SQL Server Database Project generado en Visual Studio, importando
    el esquema OLTP original de NorthWind)

NorthWindDW/
└── (SQL Server Database Project generado en Visual Studio con las
    tablas de dimensiones y hechos del modelo estrella)

NorthWindETL/
└── (Proyecto de Integration Services con los paquetes de carga
    incremental por rowversion)

README.md
```

## Diseño del modelo estrella

El diseño completo, con la justificación de negocio detrás de cada
decisión, está documentado en [`diseno/modelo-estrella.md`](./diseno/modelo-estrella.md)
y su diagrama en [`diseno/diagrama-estrella.md`](./diseno/diagrama-estrella.md).
Resumen:

- **Tabla de hechos — `FactSales`**: una fila por cada línea de detalle de
  una orden (un producto dentro de un pedido), fusionando `Orders` +
  `OrderDetails` del OLTP.
- **Dimensiones**:
  - `DimCustomer` — de `Customers`.
  - `DimEmployee` — de `Employees`.
  - `DimProduct` — fusiona `Products` + `Categories` + `Suppliers`
    (desnormalizado, sin necesidad de *join* adicional para reportes).
  - `DimShipper` — de `Shippers`.
  - `DimDate` — dimensión de tiempo generada (no existe en el OLTP), con
    una fila por cada fecha del rango de operación del negocio.

## ETL — Carga del Data Warehouse

La carga del modelo dimensional se implementa en `NorthWindETL` (Integration
Services) siguiendo un patrón de **carga incremental por `rowversion`**: cada
tabla (dimensiones y `FactSales`) tiene su propio stored procedure de captura
de cambios y registra la última versión procesada en `PackageConfig`, de modo
que solo se leen los registros modificados desde la ejecución anterior.

Los detalles de la arquitectura y las reglas de negocio del ETL están
documentados en [`diseno/reglas-negocio-etl.md`](./diseno/reglas-negocio-etl.md).

## Flujo de trabajo del grupo

Cada integrante trabaja en su propia rama y entrega su parte mediante un
Pull Request hacia `main`
