[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$reportDefinition = Join-Path $PSScriptRoot 'NorthWind-Visualizacion.Report\definition'
$pagesRoot = Join-Path $reportDefinition 'pages'
$visualSchema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.9.0/schema.json'
$pageSchema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json'
$pagesSchema = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.1.0/schema.json'

function New-Literal([string]$Value) {
    [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = $Value } } }
}

function New-ColumnField([string]$Table, [string]$Property) {
    [ordered]@{ Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Entity = $Table } }; Property = $Property } }
}

function New-MeasureField([string]$Table, [string]$Property) {
    [ordered]@{ Measure = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Entity = $Table } }; Property = $Property } }
}

function New-AggregationField([string]$Table, [string]$Property) {
    [ordered]@{
        Aggregation = [ordered]@{
            Expression = [ordered]@{ Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Entity = $Table } }; Property = $Property } }
            Function = 0
        }
    }
}

function New-ColumnProjection([string]$Table, [string]$Property, [bool]$Active = $false) {
    $projection = [ordered]@{
        field = New-ColumnField $Table $Property
        queryRef = "$Table.$Property"
        nativeQueryRef = $Property
    }
    if ($Active) { $projection.active = $true }
    $projection
}

function New-MeasureProjection([string]$Table, [string]$Property) {
    [ordered]@{
        field = New-MeasureField $Table $Property
        queryRef = "$Table.$Property"
        nativeQueryRef = $Property
    }
}

function New-Position([int]$X, [int]$Y, [int]$Width, [int]$Height, [int]$Order) {
    [ordered]@{ x = $X; y = $Y; z = $Order; height = $Height; width = $Width; tabOrder = $Order }
}

function New-TitleObject([string]$Text) {
    [ordered]@{
        title = @([ordered]@{
            properties = [ordered]@{
                show = New-Literal 'true'
                text = New-Literal "'$Text'"
                fontSize = New-Literal '13D'
                fontColor = [ordered]@{ solid = [ordered]@{ color = New-Literal "'#1B263B'" } }
            }
        })
    }
}

function New-Textbox([string]$Name, [string]$Text, [int]$X, [int]$Y, [int]$Width, [int]$Height, [int]$Order, [string]$FontSize = '24px', [string]$Color = '#1B263B') {
    [ordered]@{
        '$schema' = $visualSchema
        name = $Name
        position = New-Position $X $Y $Width $Height $Order
        visual = [ordered]@{
            visualType = 'textbox'
            objects = [ordered]@{
                general = @([ordered]@{
                    properties = [ordered]@{
                        paragraphs = @([ordered]@{
                            textRuns = @([ordered]@{
                                value = $Text
                                textStyle = [ordered]@{ fontFamily = 'Segoe UI Semibold'; fontSize = $FontSize; color = $Color }
                            })
                            horizontalTextAlignment = 'left'
                        })
                    }
                })
            }
            visualContainerObjects = [ordered]@{
                background = @([ordered]@{ properties = [ordered]@{ show = New-Literal 'false' } })
                border = @([ordered]@{ properties = [ordered]@{ show = New-Literal 'false' } })
                padding = @([ordered]@{ properties = [ordered]@{ top = New-Literal '0D'; bottom = New-Literal '0D'; left = New-Literal '0D'; right = New-Literal '0D' } })
            }
        }
    }
}

function New-Slicer([string]$Name, [string]$Table, [string]$Property, [string]$Label, [int]$X, [int]$Y, [int]$Width, [int]$Order) {
    [ordered]@{
        '$schema' = $visualSchema
        name = $Name
        position = New-Position $X $Y $Width 80 $Order
        visual = [ordered]@{
            visualType = 'slicer'
            query = [ordered]@{ queryState = [ordered]@{ Values = [ordered]@{ projections = @(New-ColumnProjection $Table $Property) } } }
            objects = [ordered]@{
                data = @([ordered]@{ properties = [ordered]@{ mode = New-Literal "'Dropdown'" } })
                header = @([ordered]@{ properties = [ordered]@{ show = New-Literal 'true'; text = New-Literal "'$Label'" } })
            }
            visualContainerObjects = [ordered]@{
                padding = @([ordered]@{ properties = [ordered]@{ top = New-Literal '8D'; bottom = New-Literal '8D'; left = New-Literal '8D'; right = New-Literal '8D' } })
            }
        }
    }
}

function New-Card([string]$Name, [string[]]$Measures, [int]$X, [int]$Y, [int]$Width, [int]$Height, [int]$Order) {
    $projections = foreach ($measure in $Measures) { New-MeasureProjection 'FactSales' $measure }
    [ordered]@{
        '$schema' = $visualSchema
        name = $Name
        position = New-Position $X $Y $Width $Height $Order
        visual = [ordered]@{
            visualType = 'cardVisual'
            query = [ordered]@{ queryState = [ordered]@{ Data = [ordered]@{ projections = @($projections) } } }
            objects = [ordered]@{
                value = @([ordered]@{ properties = [ordered]@{ fontSize = New-Literal '26D' }; selector = [ordered]@{ id = 'default' } })
                label = @([ordered]@{ properties = [ordered]@{ fontSize = New-Literal '11D' }; selector = [ordered]@{ id = 'default' } })
                padding = @([ordered]@{ properties = [ordered]@{ paddingUniform = New-Literal '8D' }; selector = [ordered]@{ id = 'default' } })
                layout = @([ordered]@{ properties = [ordered]@{ paddingUniform = New-Literal '0D' }; selector = [ordered]@{ id = 'default' } })
            }
            visualContainerObjects = [ordered]@{
                padding = @([ordered]@{ properties = [ordered]@{ top = New-Literal '8D'; bottom = New-Literal '8D'; left = New-Literal '12D'; right = New-Literal '12D' }; selector = [ordered]@{ id = 'default' } })
                spacing = @([ordered]@{ properties = [ordered]@{ customizeSpacing = New-Literal 'true'; verticalSpacing = New-Literal '2D' }; selector = [ordered]@{ id = 'default' } })
            }
        }
    }
}

function New-TopNFilter([string]$Table, [string]$Property, [int]$Count) {
    $dimensionAlias = $Table.Substring(0, 1).ToLowerInvariant()
    [ordered]@{
        name = "Filter$([guid]::NewGuid().ToString('N').Substring(0,24))"
        field = New-ColumnField $Table $Property
        type = 'TopN'
        filter = [ordered]@{
            Version = 2
            From = @(
                [ordered]@{
                    Name = 'subquery'
                    Expression = [ordered]@{
                        Subquery = [ordered]@{
                            Query = [ordered]@{
                                Version = 2
                                From = @(
                                    [ordered]@{ Name = $dimensionAlias; Entity = $Table; Type = 0 },
                                    [ordered]@{ Name = 'f'; Entity = 'FactSales'; Type = 0 }
                                )
                                Select = @([ordered]@{
                                    Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = $dimensionAlias } }; Property = $Property }
                                    Name = 'field'
                                })
                                OrderBy = @([ordered]@{
                                    Direction = 2
                                    Expression = [ordered]@{
                                        Aggregation = [ordered]@{
                                            Expression = [ordered]@{ Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'f' } }; Property = 'TotalVenta' } }
                                            Function = 0
                                        }
                                    }
                                })
                                Top = $Count
                            }
                        }
                    }
                    Type = 2
                },
                [ordered]@{ Name = $dimensionAlias; Entity = $Table; Type = 0 }
            )
            Where = @([ordered]@{
                Condition = [ordered]@{
                    In = [ordered]@{
                        Expressions = @([ordered]@{ Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = $dimensionAlias } }; Property = $Property } })
                        Table = [ordered]@{ SourceRef = [ordered]@{ Source = 'subquery' } }
                    }
                }
            })
        }
        howCreated = 'User'
    }
}

function New-Chart([string]$Name, [string]$VisualType, [string]$CategoryTable, [string]$CategoryProperty, [string]$Measure, [string]$Title, [int]$X, [int]$Y, [int]$Width, [int]$Height, [int]$Order, [string]$SortDirection = 'Descending', [bool]$Top10 = $false) {
    $chart = [ordered]@{
        '$schema' = $visualSchema
        name = $Name
        position = New-Position $X $Y $Width $Height $Order
        visual = [ordered]@{
            visualType = $VisualType
            query = [ordered]@{
                queryState = [ordered]@{
                    Category = [ordered]@{ projections = @(New-ColumnProjection $CategoryTable $CategoryProperty $true) }
                    Y = [ordered]@{ projections = @(New-MeasureProjection 'FactSales' $Measure) }
                }
                sortDefinition = [ordered]@{
                    sort = @([ordered]@{ field = New-MeasureField 'FactSales' $Measure; direction = $SortDirection })
                    isDefaultSort = $true
                }
            }
            objects = [ordered]@{
                labels = @([ordered]@{ properties = [ordered]@{ show = New-Literal 'true'; fontSize = New-Literal '9D' } })
            }
            visualContainerObjects = New-TitleObject $Title
        }
    }
    if ($Top10) {
        $chart.filterConfig = [ordered]@{ filters = @(New-TopNFilter $CategoryTable $CategoryProperty 10) }
    }
    $chart
}

function New-Matrix([string]$Name, [object[]]$Rows, [string[]]$Measures, [string]$Title, [int]$X, [int]$Y, [int]$Width, [int]$Height, [int]$Order) {
    $rowProjections = foreach ($row in $Rows) { New-ColumnProjection $row.Table $row.Property }
    $measureProjections = foreach ($measure in $Measures) { New-MeasureProjection 'FactSales' $measure }
    [ordered]@{
        '$schema' = $visualSchema
        name = $Name
        position = New-Position $X $Y $Width $Height $Order
        visual = [ordered]@{
            visualType = 'pivotTable'
            query = [ordered]@{
                queryState = [ordered]@{
                    Rows = [ordered]@{ projections = @($rowProjections) }
                    Values = [ordered]@{ projections = @($measureProjections) }
                }
                sortDefinition = [ordered]@{
                    sort = @([ordered]@{ field = New-MeasureField 'FactSales' $Measures[0]; direction = 'Descending' })
                    isDefaultSort = $true
                }
            }
            objects = [ordered]@{
                columnHeaders = @([ordered]@{ properties = [ordered]@{ columnAdjustment = New-Literal "'growToFit'"; autoSizeColumnWidth = New-Literal 'true' } })
            }
            visualContainerObjects = New-TitleObject $Title
        }
    }
}

function Write-JsonFile([string]$Path, [object]$Value) {
    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
}

function Write-Page([string]$PageName, [string]$DisplayName, [object[]]$Visuals) {
    $pagePath = Join-Path $pagesRoot $PageName
    $visualRoot = Join-Path $pagePath 'visuals'
    if (-not (Test-Path -LiteralPath $visualRoot)) { New-Item -ItemType Directory -Path $visualRoot -Force | Out-Null }

    Write-JsonFile (Join-Path $pagePath 'page.json') ([ordered]@{
        '$schema' = $pageSchema
        name = $PageName
        displayName = $DisplayName
        displayOption = 'FitToPage'
        height = 720
        width = 1280
    })

    foreach ($visual in $Visuals) {
        Write-JsonFile (Join-Path $visualRoot "$($visual.name)\visual.json") $visual
    }
}

$homePage = '4a761159fc9d4e33a001'
$page1 = '91106501b48d49118459'
$page2 = 'b24ae918d7c64f3aa102'
$page3 = 'c37bf029e8a74d11bc03'

$homeVisuals = @(
    (New-Textbox '00000000000000000001' 'NorthWind — Panel de decisiones' 24 20 760 52 1 '28px'),
    (New-Textbox '00000000000000000002' 'Resumen ejecutivo de ventas, productos, clientes y desempeño comercial' 24 72 1000 36 2 '15px' '#4B5563'),
    (New-Textbox '00000000000000000003' 'Angel Christian Flores Lazarte · Daniela Zapata Pari · Kevin Omar Mamani Quispe' 24 112 1120 32 3 '12px' '#4B5563'),
    (New-Card '00000000000000000004' @('Ventas netas','Unidades','Pedidos','Ticket promedio') 24 160 1232 120 4),
    (New-Textbox '00000000000000000005' 'Explora el reporte' 24 320 560 44 5 '22px'),
    (New-Textbox '00000000000000000006' '1. Resumen de ventas' 24 384 360 40 6 '18px' '#0F6CBD'),
    (New-Textbox '00000000000000000007' 'Indicadores principales, evolución mensual y aporte de cada categoría.' 24 428 360 72 7 '13px' '#4B5563'),
    (New-Textbox '00000000000000000008' '2. Productos y clientes' 440 384 360 40 8 '18px' '#0F6CBD'),
    (New-Textbox '00000000000000000009' 'Top 10 dinámico de productos y clientes, detalle comercial y filtros.' 440 428 360 72 9 '13px' '#4B5563'),
    (New-Textbox '00000000000000000010' '3. Desempeño comercial' 856 384 376 40 10 '18px' '#0F6CBD'),
    (New-Textbox '00000000000000000011' 'Ventas, pedidos y ticket por empleado; distribución por país del cliente.' 856 428 376 72 11 '13px' '#4B5563'),
    (New-Textbox '00000000000000000012' 'Use las pestañas inferiores para navegar. Todos los indicadores responden a los filtros de cada página.' 24 568 1208 56 12 '14px' '#1B263B'),
    (New-Textbox '00000000000000000013' 'Fuente: NorthWindDW · Modo Import · Actualización validada el 23/10/2026' 24 648 1208 32 13 '11px' '#6B7280')
)

$page1Visuals = @(
    (New-Textbox '10000000000000000001' 'Resumen de ventas' 24 20 560 52 1),
    (New-Slicer '10000000000000000002' 'Date' 'CalendarYear' 'Año' 872 16 168 2),
    (New-Slicer '10000000000000000003' 'Date' 'MonthName' 'Mes' 1056 16 200 3),
    (New-Card '10000000000000000004' @('Ventas netas','Unidades','Pedidos','Ticket promedio') 24 112 1232 120 4),
    (New-Chart '10000000000000000005' 'lineChart' 'Date' 'YearMonth' 'Ventas netas' 'Evolución mensual de ventas' 24 248 600 448 5 'Ascending'),
    (New-Chart '10000000000000000006' 'barChart' 'Product' 'CategoryName' 'Ventas netas' 'Ventas por categoría' 640 248 616 448 6)
)

$page2Visuals = @(
    (New-Textbox '20000000000000000001' 'Productos y clientes' 24 20 520 52 1),
    (New-Slicer '20000000000000000002' 'Date' 'CalendarYear' 'Año' 720 16 144 2),
    (New-Slicer '20000000000000000003' 'Date' 'MonthName' 'Mes' 880 16 160 3),
    (New-Slicer '20000000000000000004' 'Product' 'CategoryName' 'Categoría' 1056 16 200 4),
    (New-Chart '20000000000000000005' 'barChart' 'Product' 'ProductName' 'Ventas netas' 'Top 10 productos por ventas' 24 112 392 300 5 'Descending' $true),
    (New-Chart '20000000000000000006' 'barChart' 'Customer' 'CompanyName' 'Ventas netas' 'Top 10 clientes por ventas' 432 112 392 300 6 'Descending' $true),
    (New-Matrix '20000000000000000007' @([ordered]@{Table='Customer';Property='CompanyName'},[ordered]@{Table='Customer';Property='Country'}) @('Ventas netas','Pedidos') 'Detalle de clientes' 840 112 416 584 7),
    (New-Slicer '20000000000000000008' 'Customer' 'Country' 'País del cliente' 24 432 184 8),
    (New-Textbox '20000000000000000009' 'Los rankings se actualizan con los filtros seleccionados.' 224 440 584 48 9 '12px' '#4B5563')
)

$page3Visuals = @(
    (New-Textbox '30000000000000000001' 'Desempeño comercial' 24 20 560 52 1),
    (New-Slicer '30000000000000000002' 'Date' 'CalendarYear' 'Año' 888 16 168 2),
    (New-Slicer '30000000000000000003' 'Date' 'MonthName' 'Mes' 1072 16 184 3),
    (New-Chart '30000000000000000004' 'barChart' 'Employee' 'Full Name' 'Ventas netas' 'Ventas por empleado' 24 112 392 584 4),
    (New-Matrix '30000000000000000005' @([ordered]@{Table='Employee';Property='Full Name'}) @('Ventas netas','Pedidos','Ticket promedio') 'Indicadores por empleado' 432 112 392 584 5),
    (New-Chart '30000000000000000006' 'barChart' 'Customer' 'Country' 'Ventas netas' 'Ventas por país del cliente' 840 112 416 456 6),
    (New-Textbox '30000000000000000007' 'Ventas atribuidas al empleado del pedido. El período de 1998 está incompleto: finaliza el 6 de mayo.' 848 584 400 88 7 '12px' '#4B5563')
)

Write-Page $homePage 'Inicio' $homeVisuals
Write-Page $page1 'Resumen de ventas' $page1Visuals
Write-Page $page2 'Productos y clientes' $page2Visuals
Write-Page $page3 'Desempeño comercial' $page3Visuals

Write-JsonFile (Join-Path $pagesRoot 'pages.json') ([ordered]@{
    '$schema' = $pagesSchema
    pageOrder = @($homePage, $page1, $page2, $page3)
    activePageName = $homePage
})

Write-Host 'Reporte PBIR generado: 4 páginas, 35 visuales.'
