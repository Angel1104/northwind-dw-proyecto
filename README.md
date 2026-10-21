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

## Estructura del repositorio

```
diseno/
├── modelo-estrella.md       (justificacion del diseño: Fact, Dim, por que)
├── diagrama-estrella.md     (diagrama entidad-relacion, Mermaid)
└── pruebas-integridad.sql   (script de validacion del modelo implementado)

NorthWindOLTP/
└── (SQL Server Database Project generado en Visual Studio, importando
    el esquema OLTP original de NorthWind)

NorthWindDW/
└── (SQL Server Database Project generado en Visual Studio con las
    tablas de dimensiones y hechos del modelo estrella)

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

## Flujo de trabajo del grupo

Cada integrante trabaja en su propia rama y entrega su parte mediante un
Pull Request hacia `main`:

