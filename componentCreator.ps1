Add-Type -AssemblyName PresentationFramework

$componentFile = "./UIComponents.json"
$screenlayoutFile = "./Screenlayout.json"

$windowPropertySet = @{
    "Type"  = "Windows.Window"
    "Height" = "768"
    "Width" = "1024"
    "Title" = "Crimson Reign Character Builder"
    "WindowStartupLocation" ="CenterScreen"    
}

### FUNCTION DEFINITIONS ####

function createUIElement([hashtable] $propertySet)
{
    $UIcontrol = New-Object $($propertySet.Type)
    $objectType = $propertySet.Type
    $propertySet.Remove("Type")
    $propertySet.Keys | ForEach-Object { $UIcontrol.$_ = $propertySet.$_ }
    $propertySet.Add("Type",$objectType)

    return $UIcontrol
}

function setUpMasterGrid($elementList)
{
    [int]$numRows = [math]::Floor($elementList.Count / $maxCols)
    [int]$numCols = $elementList.Count -gt $maxCols ? $maxCols : $elementList.Count

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

function createSubGrids($elementList)
{
    $elementList | ForEach-Object {
        $grid = New-Object Windows.Controls.Grid
        $grid.Name = $_
        $masterGrid.AddChild($grid)
    }
}

function getGridDimensions($grid)
{
    $rMax = 0
    $cMax = 0
    $grid.Children | ForEach-Object {
        if($_.GetValue([Windows.Controls.Grid]::RowProperty) -gt $rMax) { $rMax = $_.GetValue([Windows.Controls.Grid]::RowProperty) }
        if($_.GetValue([Windows.Controls.Grid]::ColumnProperty) -gt $cMax) { $cMax = $_.GetValue([Windows.Controls.Grid]::ColumnProperty) }
    }

    return @{
        "Row"=$rMax
        "Column"=$cMax
    }
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

### MAIN PROGRAM ####

# $grids           = @{}
$elements = Get-Content -Path $componentFile | ConvertFrom-Json
$screenLayout = Get-Content -Path $screenlayoutFile | ConvertFrom-Json

$window = createUIElement $windowPropertySet
$masterGrid = New-Object Windows.Controls.Grid
$masterGrid.Name = "masterGrid"
$maxCols = 3

$gridNames = ($screenLayout | Get-Member -Type NoteProperty).Name

setUpMasterGrid $gridNames
createSubGrids $gridNames

$gridNames | ForEach-Object {
    $gridName = $_
    $grid = $masterGrid.Children | Where-Object {$_.Name -eq $gridName}
    placeControl $grid $screenlayout.$gridName.offsets.Row $screenlayout.$gridName.offsets.Column $masterGrid
}

# need to place the ui controls next
# iterate through the screen layout, get the UI Element type
# iterate through the element type and identify how to many rows and columns to create
# then place the element on the grid

exit 0

$window.ShowDialog() | Out-Null