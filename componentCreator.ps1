Add-Type -AssemblyName PresentationFramework

$uiComponentsFile = "./UIComponents.json"
$uiElementsFile = "./UIElements.json"
$screenlayoutFile = "./Screenlayout.json"

$uiComponents = Get-Content -Path $uiComponentsFile | ConvertFrom-Json
$uiElements = Get-Content -Path $uiElementsFile | ConvertFrom-Json
$screenLayout = Get-Content -Path $screenlayoutFile | ConvertFrom-Json

$maxCols = 3

### FUNCTION DEFINITIONS ####

function createUIElement($propertySet)
{
    $p = "Type"
    $UItype = $propertySet.$p
    $UIcontrol = New-Object $($propertySet.$p)
    $propertySet.PSObject.properties.remove($p)

    ($propertySet | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
        $property = $_
        $UIcontrol.$_ = $propertySet.$property
    }

    $propertySet | Add-Member -NotePropertyName $p -NotePropertyValue $UItype
    return $UIcontrol
}

function setUpMasterGrid($numElements)
{
    [int]$numRows = [math]::Floor($elementList.Count / $maxCols)
    [int]$numCols = $numElements -gt $maxCols ? $maxCols : $numElements

    if ($numRows)
    {
        1..$numRows | ForEach-Object {
            $row = New-Object Windows.Controls.RowDefinition
            $masterGrid.RowDefinitions.Add($row)
        }
    }

    if ($numCols)
    {
        1..$numCols | ForEach-Object {
            $column = New-Object Windows.Controls.ColumnDefinition
            $masterGrid.ColumnDefinitions.Add($column)
        }
    }
}

function createSubGrids($gridList)
{
    $gridList | ForEach-Object {
        $grid = New-Object Windows.Controls.Grid
        $grid.Name = $_
        $grid.HorizontalAlignment = "center"
        $grid.VerticalAlignment = "top"
        #$grid.ShowGridLines = "True"
        $masterGrid.AddChild($grid)
    }
}

function getGridDimensions($grid)
{
    return @{
        "Row"=$($grid.RowDefinitions.Count)
        "Column"=$($grid.ColumnDefinitions.Count)
    }
}

function getGridByName($name)
{
    return ($masterGrid.Children | Where-Object {$_.Name -eq $name})
}

function getElementLocation($control)
{
    return @{
        "Row"=$control.GetValue([Windows.Controls.Grid]::RowProperty)
        "Column"=$control.GetValue([Windows.Controls.Grid]::ColumnProperty)
    }
}

function placeControl($control, [int] $row, [int] $column, $parent)
{   
    # Write-Output "Placing control $($control.Name) of type $(($control.GetType()).Name) at Row $row, Column $column on Grid $($parent.Name)"
    $control.SetValue([Windows.Controls.Grid]::RowProperty,$row)
    $control.SetValue([Windows.Controls.Grid]::ColumnProperty,$column)

    if ( ($control.GetType()).Name -ne 'Grid') { $parent.AddChild($control) }            # Add the control if it is not a grid, as this is handled during grid setup
}


function determineMaxGridSize($coordinates)
{
    # receive a list of row, column coordinates
    # return a hashtable with the largest value in a Row = , Col = , format
    $maxR = 0
    $maxC = 0

    $coordinates | ForEach-Object {
        if ($($_.Row) -gt $maxR) { $maxR = $($.Row)}
        if ($($_.Column) -gt $maxC) { $maxC = $($_.Column)}
    }

    return @{
        "Rows"=$maxR
        "Columns"=$maxC
    }

}

function resizeGrid([hashtable] $position, $grid)
{

    if ($position.Rows)
    {
        1..$position.Rows | ForEach-Object {
            $row = New-Object Windows.Controls.RowDefinition
            $grid.RowDefinitions.Add($row)
            }
    }

    if($position.Columns)
    {
        1..$position.Columns | ForEach-Object {
            $column = New-Object Windows.Controls.ColumnDefinition
            $grid.ColumnDefinitions.Add($column)
        }
    }
}
### MAIN PROGRAM ####

$form = createUIElement $uiComponents.window
$masterGrid = createUIElement $uiComponents.masterGrid

$gridNames = ($screenLayout | Get-Member -Type NoteProperty).Name

setUpMasterGrid $gridNames.Count
createSubGrids $gridNames

$gridNames | ForEach-Object {
    $gridName = $_
    $grid = getGridByName $gridName
    placeControl $grid $screenlayout.$gridName.offsets.Row $screenlayout.$gridName.offsets.Column $masterGrid
}

$gridNames | ForEach-Object {

    $_
    $grouping = $_
    $controlGroup = $screenLayout.$grouping.UIElement
    $control = $uiElements.$controlGroup

    $gridSize = determineMaxGridSize $uiElements.$($screenLayout.$grouping.UIElement).Offset # Determine how large the grid needs to be fit the controls
    $targetGrid = getGridByName $grouping                                                    # Get the name of the target grid based on the data element name

    resizeGrid $gridSize $targetGrid

    $column = New-Object Windows.Controls.ColumnDefinition
    $targetGrid.ColumnDefinitions.Add($column)

    $control.Element | ForEach-Object {
        $controlElement = $_
        $propertySet = $uiComponents.$controlElement
        $_
        ($grouping, $controlGroup, $controlElement -join "_")
        $propertySet | Add-Member -NotePropertyName Name -NotePropertyValue ($grouping, $controlGroup, $controlElement -join "_")
        $propertySet
        $component = createUIElement $propertySet $controlGroup $grouping
        $coords = ($control | Where-Object { $_.Element -eq $controlElement }).Offset
        placeControl $component $coords.Row $coords.Column $targetGrid
    }
}

$form.AddChild($masterGrid)

$form.ShowDialog() | Out-Null