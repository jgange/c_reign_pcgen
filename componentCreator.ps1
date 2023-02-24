Add-Type -AssemblyName PresentationFramework

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

function resizeGrid()
{
    # This function resizes an existing grid to prepare it for placing controls
    # need to determine how many rows and columns to create and place on the grid

}
### MAIN PROGRAM ####

$uiComponentsFile = "./UIComponents.json"
$uiElementsFile = "./UIElements.json"
$screenlayoutFile = "./Screenlayout.json"

# $grids           = @{}
$uiComponents = Get-Content -Path $uiComponentsFile | ConvertFrom-Json
$uiElements = Get-Content -Path $uiElementsFile | ConvertFrom-Json
$screenLayout = Get-Content -Path $screenlayoutFile | ConvertFrom-Json

$form = createUIElement $uiComponents.window

$masterGrid = New-Object Windows.Controls.Grid
$masterGrid.Name = "masterGrid"
$maxCols = 3

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
# then place the element on the grid

$grouping = "Attributes"
$controlGroup = $screenLayout.$grouping.UIElement
$control = $uiElements.$controlGroup

$control | ForEach-Object {
    $propertySet = $uiComponents.$($_.Name)
    #createUIElement $propertySet
}

$grid = getGridByName $grouping

$form.AddChild($masterGrid)

exit 0

# loop through the ui elements to get the details of what to build
$gridNames | ForEach-Object {
    $control  = $screenLayout.$_.UIElement
    $position = $UIelements.$control.Offset
}

$form.ShowDialog() | Out-Null