param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'NorthWind-Visualizacion.SemanticModel\model.bim')
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repoRoot
try {
    $raw = (& git show 'origin/feature/NorthWindOLAP-Kevin:NorthWindOLAP/NorthWindOLAP/NothWind.bim') -join "`n"
}
finally {
    Pop-Location
}

$bim = $raw | ConvertFrom-Json
$bim.name = 'NorthWind-Visualizacion'
$bim.compatibilityLevel = 1601

if ($bim.PSObject.Properties.Name -contains 'compatibilityMode') {
    $bim.PSObject.Properties.Remove('compatibilityMode')
}

if ($bim.model.PSObject.Properties.Name -contains 'defaultPowerBIDataSourceVersion') {
    $bim.model.defaultPowerBIDataSourceVersion = 'powerBI_V3'
}
else {
    $bim.model | Add-Member -NotePropertyName defaultPowerBIDataSourceVersion -NotePropertyValue 'powerBI_V3'
}

if ($bim.model.PSObject.Properties.Name -contains 'sourceQueryCulture') {
    $bim.model.sourceQueryCulture = 'es-BO'
}
else {
    $bim.model | Add-Member -NotePropertyName sourceQueryCulture -NotePropertyValue 'es-BO'
}

if ($bim.model.PSObject.Properties.Name -contains 'discourageImplicitMeasures') {
    $bim.model.discourageImplicitMeasures = $true
}
else {
    $bim.model | Add-Member -NotePropertyName discourageImplicitMeasures -NotePropertyValue $true
}

$dataSourceName = 'SqlServer 127.0.0.1 NorthWindDW'
$bim.model.dataSources = @(
    [pscustomobject]@{
        type = 'structured'
        name = $dataSourceName
        connectionDetails = [pscustomobject]@{
            protocol = 'tds'
            address = [pscustomobject]@{
                server = '127.0.0.1'
                database = 'NorthWindDW'
            }
        }
        credential = [pscustomobject]@{
            AuthenticationKind = 'UsernamePassword'
            kind = 'SQL'
            path = '127.0.0.1;NorthWindDW'
            Username = 'sa'
            EncryptConnection = $false
        }
    }
)

$sourceTables = @{
    Customer = 'DimCustomer'
    Date = 'DimDate'
    Employee = 'DimEmployee'
    Product = 'DimProduct'
    Shipper = 'DimShipper'
    FactSales = 'FactSales'
}

foreach ($table in $bim.model.tables) {
    $sourceTable = $sourceTables[$table.name]
    foreach ($partition in $table.partitions) {
        $queryName = 'dbo_' + $sourceTable
        if ($partition.PSObject.Properties.Name -contains 'mode') {
            $partition.mode = 'import'
        }
        else {
            $partition | Add-Member -NotePropertyName mode -NotePropertyValue 'import'
        }
        $partition.source = [pscustomobject]@{
            type = 'm'
            expression = @(
                'let',
                '    Source = Sql.Database("127.0.0.1", "NorthWindDW", [CreateNavigationProperties=false]),',
                ('    ' + $queryName + ' = Source{[Schema="dbo",Item="' + $sourceTable + '"]}[Data]'),
                'in',
                ('    ' + $queryName)
            )
        }
    }
}

$dateTable = $bim.model.tables | Where-Object name -eq 'Date'
$fullDate = $dateTable.columns | Where-Object name -eq 'FullDate'
$fullDate.dataType = 'dateTime'
$fullDate.isHidden = $false
$fullDate | Add-Member -NotePropertyName formatString -NotePropertyValue 'dd/MM/yyyy' -Force
$monthName = $dateTable.columns | Where-Object name -eq 'MonthName'
$monthName | Add-Member -NotePropertyName sortByColumn -NotePropertyValue 'MonthNumberOfYear' -Force

if (-not ($dateTable.columns | Where-Object name -eq 'YearMonth')) {
    $dateTable.columns += [pscustomobject]@{
        type = 'calculated'
        name = 'YearMonth'
        dataType = 'dateTime'
        expression = "IF('Date'[DateKey] = 0, BLANK(), DATE('Date'[CalendarYear], 'Date'[MonthNumberOfYear], 1))"
        formatString = 'MMM yyyy'
        summarizeBy = 'none'
    }
}

$fact = $bim.model.tables | Where-Object name -eq 'FactSales'
$measures = @(
    [pscustomobject]@{
        name = 'Ventas netas'
        expression = 'SUM(FactSales[TotalVenta])'
        formatString = '#,0.00'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Unidades'
        expression = 'SUM(FactSales[Quantity])'
        formatString = '#,0'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Pedidos'
        expression = 'DISTINCTCOUNT(FactSales[OrderID])'
        formatString = '#,0'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Ticket promedio'
        expression = 'DIVIDE([Ventas netas], [Pedidos])'
        formatString = '#,0.00'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Ventas brutas'
        expression = 'SUMX(FactSales, FactSales[Quantity] * FactSales[UnitPrice])'
        formatString = '#,0.00'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Descuento monetario'
        expression = '[Ventas brutas] - [Ventas netas]'
        formatString = '#,0.00'
        displayFolder = 'Medidas'
    },
    [pscustomobject]@{
        name = 'Descuento efectivo %'
        expression = 'DIVIDE([Descuento monetario], [Ventas brutas])'
        formatString = '0.00%'
        displayFolder = 'Medidas'
    }
)

if ($fact.PSObject.Properties.Name -contains 'measures') {
    $fact.measures = $measures
}
else {
    $fact | Add-Member -NotePropertyName measures -NotePropertyValue $measures
}

$json = $bim | ConvertTo-Json -Depth 100
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, $json, $utf8NoBom)

Write-Output "Modelo generado: $OutputPath"
