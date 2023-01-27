Add-Type -AssemblyName PresentationFramework

### Declarations ####

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

$removeButtonPropertySet = @{
    "Type"="System.Windows.Controls.Button"
    "Name"="Remove"
    "Content"="-"
    "Height"=30
    "Width"=30
}

$ComboBoxPropertySet = @{
    "Type"="System.Windows.Controls.ComboBox"
    "Height"=30
    "Width"=150
}

$elementList  = @("Traits","Backgrounds") 
$traitList = @("Affinity","Alert","Arrogant","Balanced","Brash","Captivating")
$textHeight = 30

### Function Definitions ###
function createUIElement([hashtable] $propertySet)
{
    $UIcontrol = New-Object $($propertySet.Type)
    $objectType = $propertySet.Type
    $propertySet.Remove("Type")
    $propertySet.Keys | ForEach-Object { $UIcontrol.$_ = $propertySet.$_ }
    $propertySet.Add("Type",$objectType)

    return $UIcontrol
}

function InitializeGrid([System.Windows.Window] $window, [System.Windows.Controls.Grid] $grid)
{   
    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = $textHeight
    $grid.RowDefinitions.Add($row)

    1..3 | ForEach-Object {
        $column = New-Object Windows.Controls.ColumnDefinition
        $grid.ColumnDefinitions.Add($column)
    }
}

function buildGrids($elementList)
{
    # Iterate through the list of required grids, create the objects and add them to the master grid
    $columnCount = 0 

    $elementList | ForEach-Object {
        $grid = @{
            Name      = $_
            UIElement = New-Object Windows.Controls.Grid
        }

        $grid.UIElement.Name = $_
        $column = New-Object Windows.Controls.ColumnDefinition
        $masterGrid.ColumnDefinitions.Add($column)
        $grid.UIElement.SetValue([Windows.Controls.Grid]::ColumnProperty,$columnCount)
        $masterGrid.Children.Add($grid.UIElement)
        $columnCount++
    }
}

function createControlSet($elementList)
{
    $elementList | ForEach-Object {
        $elementName = $_
    
        $control = @{
            rowCount        = 0
            parentControl   = ($masterGrid.Children | Where-Object { $_.Name -eq $elementName }).UIElement
            controlSet      = [System.Collections.ArrayList]@()
            addItem         = createUIElement $addButtonPropertySet
            removeItem      = createUIElement $removeButtonPropertySet
            selectItem      = createUIElement $ComboBoxPropertySet
        }
        $multiControls.Add($elementName,$control)
    }
}

function placeControls($elementList)
{
    $elementList | ForEach-Object {

        $element = $_
    
        $gridInstance = ($masterGrid.Children | Where-Object { $_.Name -eq $element })
    
        InitializeGrid $window $gridInstance
    
        $gridInstance.AddChild($multiControls.$element.addItem)
        $gridInstance.AddChild($multiControls.$element.removeItem)
        $gridInstance.AddChild($multiControls.$element.selectItem)
    
        $multiControls.$element.addItem.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
        $multiControls.$element.selectItem.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
        $multiControls.$element.removeItem.SetValue([Windows.Controls.Grid]::ColumnProperty,2)
    
        $multiControls.$element.selectItem.ItemsSource = $traitList
    
        $multiControls.$element.addItem.Add_Click(
            {
                addCombobox
            }
        )
    
        $multiControls.$element.removeItem.Add_Click(
            {
                removeCombobox
            }
        )
    
        $multiControls.$element.selectItem.Add_SelectionChanged(
            {
                updateBuildPoints
            }
        )
    
    }
    
}

function addCombobox()
{
    # Add a row to the grid
    # Move both buttons down to the new row
    # Create a new combobox
    # Set the coordinates for the combobox
    # Add new combobox to the grid
    # Add the selection_changed handler
    
    [System.Windows.MessageBox]::Show($this)
    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = $textHeight
    $this.Parent.RowDefinitions.Add($row)

}

function removeCombobox()
{
    [System.Windows.MessageBox]::Show($this)
}

function updateBuildPoints()
{
    [System.Windows.MessageBox]::Show($this)
}


### Main Program ###

$window = createUIElement $windowPropertySet
$masterGrid = New-Object Windows.Controls.Grid
$window.Content = $masterGrid
$multiControls = @{}

buildGrids       $elementList
createControlSet $elementList
placeControls    $elementList

$window.ShowDialog() | Out-Null