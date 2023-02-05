Add-Type -AssemblyName PresentationFramework

$window = New-Object Windows.Window
$window.Title = "TestGrid"

$masterGrid = New-Object Windows.Controls.Grid

$elementList = @("metaData","Attributes","Backgrounds","Traits","Spells","Skills","Racial Abilities","Starting gear","Rare Items")

[int]$elements = $elementList.Count
[int]$maxCols = 3

[int]$counter = 0
[int]$rowNum  = 0
[int]$colNum  = 0

$grids = @{}

$elementList | ForEach-Object {
    [int]$rowNum = [math]::Floor($counter / $maxCols)
    [int]$colNum = $counter % $maxCols
    if ($counter % 3 -eq 0) 
    {
        #Write-Output "Add a row and column and add it to the master grid"
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
    $label = New-Object Windows.Controls.Label
    $label.Content = $_
    $rowPos = $grids.$_.Position.Row
    $colPos = $grids.$_.Position.Col
    $grid = $grids.$_.UIElement
    $grid.AddChild($label)
    #Write-Output "Set grid $_ position to Row $($grids.$_.Position.Row) by Column $($grids.$_.Position.Col)"
    $grid.SetValue([Windows.Controls.Grid]::RowProperty,$rowPos)
    $grid.SetValue([Windows.Controls.Grid]::ColumnProperty,$colPos)
    $masterGrid.AddChild($grid)
}

$window.ShowDialog()