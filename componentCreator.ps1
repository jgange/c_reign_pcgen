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

    #$propertySet | Get-Member -MemberType NoteProperty

    ($propertySet | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
        $property = $_
        #$_
        #$propertySet.$property
        $UIcontrol.$_ = $propertySet.$property
    }

    $propertySet | Add-Member -NotePropertyName $p -NotePropertyValue $UItype
    return $UIcontrol
}

function setUpMasterGrid($numElements)
{
    [int]$numRows = [math]::Floor($elementList.Count / $maxCols)
    [int]$numCols = $numElements -gt $maxCols ? $maxCols : $numElements

    for ($i=0; $i -le $numRows; $i++)
    {
        $row = New-Object Windows.Controls.RowDefinition
        $masterGrid.RowDefinitions.Add($row)
    }

    for ($i=0; $i -le $numCols; $i++)
    {
        $column = New-Object Windows.Controls.ColumnDefinition
        $masterGrid.ColumnDefinitions.Add($column)
    }

}

function createSubGrids($gridList)
{
    $gridList | ForEach-Object {
        $grid = New-Object Windows.Controls.Grid
        $grid.Name = $_
        $masterGrid.AddChild($grid)
    }
}

function getGridDimensions($grid)
{
    # Add case when object has no children
    $rMax = 0
    $cMax = 0

    if ($grid.Children)
    {
        $grid.Children | ForEach-Object {
            if($_.GetValue([Windows.Controls.Grid]::RowProperty) -gt $rMax) { $rMax = $_.GetValue([Windows.Controls.Grid]::RowProperty) }
            if($_.GetValue([Windows.Controls.Grid]::ColumnProperty) -gt $cMax) { $cMax = $_.GetValue([Windows.Controls.Grid]::ColumnProperty) }
        }
    }
    else
    {
        $rMax = $grid.GetValue([Windows.Controls.Grid]::RowProperty)
        $cMax = $grid.GetValue([Windows.Controls.Grid]::ColumnProperty)
    }

    return @{
        "Row"=$rMax
        "Column"=$cMax
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
    if ($column -gt $maxCols)
    {
        Write-Output "Bad row or column position."
        exit 1
    }
    else
    {
        $control.SetValue([Windows.Controls.Grid]::RowProperty,$row)
        $control.SetValue([Windows.Controls.Grid]::ColumnProperty,$column)
    }
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

# need to place the ui controls next
# iterate through the screen layout, get the UI Element type
# iterate through the element type and identify how to many rows and columns to create
# create the element based on the associated property set
# place the element on the grid

$grouping = "Attributes"
$controlGroup = $screenLayout.$grouping.UIElement
$control = $uiElements.$controlGroup

$gridSize = determineMaxGridSize $uiElements.$($screenLayout.$grouping.UIElement).Offset # Determine how large the grid needs to be fit the controls
$targetGrid = getGridByName $grouping                                                    # Get the name of the target grid based on the data element name

resizeGrid $gridSize $targetGrid

$control.Name | ForEach-Object {
    $controlName = $_
    $propertySet = $uiComponents.$controlName
    $component = createUIElement $propertySet
    $coords = ($control | Where-Object { $_.Name -eq $controlName }).Offset
    placeControl $component $coords.Row $coords.Column $targetGrid
}

$form.AddChild($masterGrid)

exit 0

$form.ShowDialog() | Out-Null