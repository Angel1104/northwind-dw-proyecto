# NorthWind — Proyecto OLTP y Data Warehouse

Diplomado en Ciencia de Datos — UMSS FCyT
Módulo II — Almacenamiento y Preparación de Datos
Docente: M.Sc. Juan Marcelo Claure Salinas

## Integrantes del grupo

- Angel Christian Flores Lazarte ([Angel1104](https://github.com/Angel1104))
- [Nombre completo] ([DanieZapata](https://github.com/DanieZapata))
- [Nombre completo] ([kevdev21](https://github.com/kevdev21))

## Descripción

Este repositorio contiene dos proyectos de SQL Server (`.sqlproj`), creados
en Visual Studio a partir de la base de datos NorthWind entregada para el
proyecto final:

- **`NorthWindOLTP/`**: proyecto de SQL Server Database Project con el
  esquema transaccional (OLTP) original de NorthWind.
- **`NorthWindDW/`**: proyecto de SQL Server Database Project con el modelo
  dimensional (modelo estrella) derivado del OLTP, compuesto por una tabla
  de hechos y sus tablas de dimensión.

## Estructura esperada

```
NorthWindOLTP/
└── (generado por Visual Studio al crear el SQL Server Database Project
    e importar la base NorthWind restaurada)

NorthWindDW/
└── (generado por Visual Studio con las tablas de dimensiones y hechos
    del modelo estrella)

README.md
```

## Diseño del modelo estrella

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

## Flujo de trabajo del grupo

Cada integrante trabaja en Visual Studio y sube su proyecto mediante un
Pull Request hacia `main`:

- **Daniela**: crea `NorthWindOLTP/` (SQL Server Database Project →
  Import Database, apuntando a la base NorthWind ya restaurada).
- **Kevin**: crea `NorthWindDW/` (SQL Server Database Project con las
  tablas del modelo estrella descrito arriba).
