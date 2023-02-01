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
    "Margin"="0,0,-120,0"
}

$removeButtonPropertySet = @{
    "Type"="System.Windows.Controls.Button"
    "Name"="Remove"
    "Content"="-"
    "Height"=30
    "Width"=30
    "Margin"="-120,0,0,0"
}

$ComboBoxPropertySet = @{
    "Type"="System.Windows.Controls.ComboBox"
    "Height"=30
    "Width"=150
}

$elementList  = @("Traits","Backgrounds")
$dataSet = @{
    "Traits" = @("Affinity","Alert","Arrogant","Balanced","Brash","Captivating")
    "Backgrounds" = @("Apothecary","Craftsman","Merchant")
}
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
        $multiControls.Add($elementName,$control) | Out-Null
    }
}

function placeControls($elementList)
{
    # The remove button should start as Hidden and change to visible on the first add button click

    $elementList | ForEach-Object {

        $element = $_
        $gridInstance = ($masterGrid.Children | Where-Object { $_.Name -eq $element })
        InitializeGrid $window $gridInstance

        $multiControls.$element.removeItem.Visibility = "Hidden"
    
        $gridInstance.AddChild($multiControls.$element.addItem)
        $gridInstance.AddChild($multiControls.$element.removeItem)
        $gridInstance.AddChild($multiControls.$element.selectItem)
    
        $multiControls.$element.addItem.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
        $multiControls.$element.selectItem.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
        $multiControls.$element.removeItem.SetValue([Windows.Controls.Grid]::ColumnProperty,2)
    
        $multiControls.$element.selectItem.ItemsSource = $dataSet.$element
    
        $multiControls.$element.addItem.Add_Click({ addCombobox $ComboBoxPropertySet })
        $multiControls.$element.removeItem.Add_Click({ removeCombobox })
        $multiControls.$element.selectItem.Add_SelectionChanged({ updateBuildPoints })   
    }
    
}

function addCombobox($ComboBoxPropertySet)
{   
    # Add logic to prevent selecting the same item twice in the comboboxes
    # Probably need another list which is managed with the multicontrol or something
    # only happens after something is selected - check that logic

    $elementName = $this.Parent.Name
    $grid = $this.Parent
    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = $textHeight
    $grid.RowDefinitions.Add($row)

    #$rowNumber = $multiControls.$elementName.rowCount

    #[System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.rowCount)
    $multiControls.$elementName.rowCount++
    $multiControls.$elementName.addItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.Visibility = "visible"

    $newComboBox = createUIElement $ComboBoxPropertySet
    $newComboBox.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $newComboBox.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
    $newComboBox.ItemsSource = $dataSet.$elementName
    $newComboBox.Add_SelectionChanged({ updateBuildPoints })

    $multiControls.$elementName.controlSet.Add($newComboBox)
    $grid.AddChild($newComboBox)

    #[System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.rowCount)
}

function removeCombobox()
{
    $elementName = $this.Parent.Name
    $grid = $this.Parent

    #[System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.rowCount)

    $multiControls.$elementName.rowCount--
    $currentComboBox = $multiControls.$elementName.controlSet[$multiControls.$elementName.rowCount]
    #[System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.rowCount)
    $grid.Children.Remove($currentComboBox)
    if ($multiControls.$elementName.rowCount -eq 0) { $multiControls.$elementName.removeItem.Visibility="hidden" }

    $multiControls.$elementName.addItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)

}

function updateBuildPoints()
{
    $elementName = $this.Parent.Name
    [System.Windows.MessageBox]::Show($multiControls.$elementName.rowCount)
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