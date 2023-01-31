
$windowPropertySet = @{
    "Type"  = "Windows.Window"
    "Height" = "768"
    "Width" = "1024"
    "Title" = "Crimson Reign Character Builder"
    "WindowStartupLocation" ="CenterScreen"    
}

$addButtonPropertySet = @{
    "Type"="System.Windows.Controls.Button"
    "Name"="Add"
    "Content"="+"
    "Height"=30
    "Width"=30
}

$stackPanelPropertySet = @{
    Type="System.Windows.Controls.StackPanel"
    HorizontalAlignment="Center"
    VerticalAlignment="Center"
    Height="250"
    Width="300"
    Margin="0,0,0,0"
}

function createUIElement([hashtable] $propertySet)
{
    $UIcontrol = New-Object $($propertySet.Type)
    $objectType = $propertySet.Type
    $propertySet.Remove("Type")
    $propertySet.Keys | ForEach-Object { $UIcontrol.$_ = $propertySet.$_ }
    $propertySet.Add("Type",$objectType)

    return $UIcontrol
}

function sizeGrid([int]$r,[int]$c, $emptyGrid)
{
    1..$c | ForEach-Object {
        $column = New-Object Windows.Controls.ColumnDefinition
        $column.Width="35"
        $emptyGrid.ColumnDefinitions.Add($column)
    }

    1..$r | ForEach-Object {
        $row = New-Object Windows.Controls.RowDefinition
        $row.Height="35"
        $emptyGrid.RowDefinitions.Add($row)
    }

    return $grid
}

$window = createUIElement $windowPropertySet

$grid1 = New-Object Windows.Controls.Grid
$grid2 = New-Object Windows.Controls.Grid
$grid3 = New-Object Windows.Controls.Grid

sizeGrid 3 3 $grid1
sizeGrid 3 3 $grid2
sizeGrid 3 3 $grid3

$stackPanel1 = createUIElement $stackPanelPropertySet

$window.AddChild($stackPanel1)
$stackPanel1.AddChild($grid1)
$stackPanel1.AddChild($grid2)
$stackPanel1.AddChild($grid3)

$btn1 = createUIElement $addButtonPropertySet
$btn2 = createUIElement $addButtonPropertySet
$btn3 = createUIElement $addButtonPropertySet
$btn4 = createUIElement $addButtonPropertySet
$btn5 = createUIElement $addButtonPropertySet
$btn6 = createUIElement $addButtonPropertySet
$btn7 = createUIElement $addButtonPropertySet
$btn8 = createUIElement $addButtonPropertySet
$btn9 = createUIElement $addButtonPropertySet

$grid1.AddChild($btn1)
$grid2.AddChild($btn2)
$grid3.AddChild($btn3)
$grid1.AddChild($btn4)
$grid2.AddChild($btn5)
$grid3.AddChild($btn6)
$grid1.AddChild($btn7)
$grid2.AddChild($btn8)
$grid3.AddChild($btn9)

$btn1.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
$btn2.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
$btn3.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
$btn4.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
$btn5.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
$btn6.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
$btn7.SetValue([Windows.Controls.Grid]::ColumnProperty,2)
$btn8.SetValue([Windows.Controls.Grid]::ColumnProperty,2)
$btn9.SetValue([Windows.Controls.Grid]::ColumnProperty,2)

$window.ShowDialog() | Out-Null

exit 0

$masterGrid = New-Object Windows.Controls.Grid
$window.Content = $masterGrid
$stackPanel1 = createUIElement $stackPanelPropertySet


$masterGrid.AddChild($stackPanel1)

$column1 = New-Object Windows.Controls.ColumnDefinition
$masterGrid.ColumnDefinitions.Add($column1)
$column2 = New-Object Windows.Controls.ColumnDefinition
$masterGrid.ColumnDefinitions.Add($column2)
$column3 = New-Object Windows.Controls.ColumnDefinition
$masterGrid.ColumnDefinitions.Add($column3)

$grid1 = New-Object Windows.Controls.Grid
$grid2 = New-Object Windows.Controls.Grid
$grid3 = New-Object Windows.Controls.Grid

$stackPanel1.AddChild($grid1)
$stackPanel1.AddChild($grid2)
$stackPanel1.AddChild($grid3)

$btn1 = createUIElement $addButtonPropertySet
$btn2 = createUIElement $addButtonPropertySet
$btn3 = createUIElement $addButtonPropertySet

$grid1.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
$grid2.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
$grid3.SetValue([Windows.Controls.Grid]::ColumnProperty,2)

$grid1.AddChild($btn1)
$grid2.AddChild($btn2)
$grid3.AddChild($btn3)

$window.ShowDialog() | Out-Null