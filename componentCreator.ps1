Add-Type -AssemblyName PresentationFramework

$componentFile = "./UIComponents.json"
$screenlayoutFile = "./Screenlayout.json"

$maxCols = 3

$elements = Get-Content -Path $componentFile | ConvertFrom-Json
$screenLayout = Get-Content -Path $screenlayoutFile | ConvertFrom-Json

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

function buildGrids($elementList)
{
    # Iterate through the list of required grids, create the objects and add them to the master grid
    [int]$counter = 0
    [int]$rowNum  = 0
    [int]$colNum  = 0

    $elementList | ForEach-Object {
        [int]$rowNum = [math]::Floor($counter / $maxCols)
        [int]$colNum = $counter % $maxCols
        if ($counter % 3 -eq 0)
        {
            $column = New-Object Windows.Controls.ColumnDefinition
            $row = New-Object Windows.Controls.RowDefinition
            $masterGrid.RowDefinitions.Add($row)
            $masterGrid.ColumnDefinitions.Add($column)
        }

        $grid = @{
            UIElement = New-Object Windows.Controls.Grid
            Position   = @{Row=$rowNum;Col=$colNum}
        }

        $grids.Add($_,$grid) | Out-Null
        $counter++
    }
    
    $elementList | ForEach-Object {
        $rowPos = $grids.$_.Position.Row
        $colPos = $grids.$_.Position.Col
        $grid = $grids.$_.UIElement
        $grid.Name = $_
        $grid.SetValue([Windows.Controls.Grid]::RowProperty,$rowPos)
        $grid.SetValue([Windows.Controls.Grid]::ColumnProperty,$colPos)
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
    return @{"Row"=$rMax; "Column"=$cMax}
}

function getElementLocation($control)
{
    return @{"Row"=$control.GetValue([Windows.Controls.Grid]::RowProperty);"Column"=$control.GetValue([Windows.Controls.Grid]::RowProperty)}
}

function placeControlOnGrid($control, [int] $row, [int] $column, $parent)
{
    # Get the coordinates from the layout object
    if (1 -eq 1) # place holder to check if the coordinates are valid
    {
        $control.SetValue([Windows.Controls.Grid]::RowProperty,$row)
        $control.SetValue([Windows.Controls.Grid]::ColumnProperty,$column)
    }
    getElementLocation $control
}

### MAIN PROGRAM ####

# $elements | Format-List
# $screenlayout | Format-List

$window = createUIElement $windowPropertySet
$masterGrid = New-Object Windows.Controls.Grid
$masterGrid.Name = "masterGrid"
$grids           = @{}
$gridNames = ($screenLayout | Get-Member -Type NoteProperty).Name

#$gridNames

buildGrids $gridNames

#getGridDimensions $masterGrid

$screenLayout | Get-Member -Type NoteProperty | ForEach-Object  {
    placeControlOnGrid $grids.$gridName.UIElement $grids.$gridName.Position.Row $grids.$gridName.Position.Column $masterGrid

}

exit 0

$window.ShowDialog() | Out-Null