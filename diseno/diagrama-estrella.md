# Diagrama del modelo estrella — NorthWindDW

**Responsable:** Angel Christian Flores Lazarte

```mermaid
erDiagram
    DimCustomer {
        int CustomerSK PK
        nchar_5 CustomerID
        varchar_40 CompanyName
        varchar_15 Country
    }

    DimEmployee {
        int EmployeeSK PK
        int EmployeeID
        varchar_10 FirstName
        varchar_20 LastName
        varchar_30 Title
    }

    DimProduct {
        int ProductSK PK
        int ProductID
        varchar_40 ProductName
        varchar_15 CategoryName
        varchar_40 SupplierName
        varchar_15 SupplierCountry
        money ListPrice
    }

    DimShipper {
        int ShipperSK PK
        int ShipperID
        varchar_40 CompanyName
    }

    DimDate {
        int DateKey PK
        date FullDate
        varchar_10 MonthName
        tinyint CalendarQuarter
        smallint CalendarYear
    }

    FactSales {
        int OrderID PK
        int ProductID PK
        int OrderDateKey FK
        int RequiredDateKey FK
        int ShippedDateKey FK
        int CustomerSK FK
        int EmployeeSK FK
        int ProductSK FK
        int ShipperSK FK
        smallint Quantity
        money UnitPrice
        real Discount
        money LineTotal
    }

    DimCustomer ||--o{ FactSales : "genera"
    DimEmployee ||--o{ FactSales : "atiende"
    DimProduct  ||--o{ FactSales : "se vende en"
    DimShipper  ||--o{ FactSales : "envia"
    DimDate     ||--o{ FactSales : "fecha de orden"
    DimDate     ||--o{ FactSales : "fecha requerida"
    DimDate     ||--o{ FactSales : "fecha de envio"
```

`FactSales` queda al centro, rodeada por sus cinco dimensiones — de ahí el
nombre "modelo estrella": visualmente, el diagrama tiene la forma de una
estrella con la tabla de hechos en el núcleo.

Nótese que `DimDate` se conecta tres veces a `FactSales` (una por cada
fecha de negocio de la orden), lo que en el diseño dimensional se conoce
como una dimensión de **rol múltiple**.
