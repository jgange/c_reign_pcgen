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
    $row.Height = 40 
    $grid.RowDefinitions.Add($row)

    1..3 | ForEach-Object {
        $column = New-Object Windows.Controls.ColumnDefinition
        $grid.ColumnDefinitions.Add($column)
    }
}

function addCombobox()
{
     [System.Windows.MessageBox]::Show($this)
     $row = New-Object Windows.Controls.RowDefinition
     $row.Height = 40 
     $this.Parent.RowDefinitions.Add($row)

}

function buildGrids($elementList)
{
    # Iterate through the list of required grids, create the objects and add them to the master grid
    $elementList | ForEach-Object {
        $grid = @{
            Name      = $_
            UIElement = New-Object Windows.Controls.Grid
        }
        $grid.UIElement.Name = $_
        $masterGrid.Children.Add($grid.UIElement)
    }
}
### Main Program ###

$window = createUIElement $windowPropertySet
$multiControls = @{}
$masterGrid = New-Object Windows.Controls.Grid
$window.Content = $masterGrid

buildGrids $elementList

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

exit 0

$traitGrid = ($grids | Where-Object { $_.Name -eq "Traits" }).UIElement

InitializeGrid $window $traitGrid

$traitGrid.AddChild($traitUIElements.addItem)
$traitGrid.AddChild($traitUIElements.removeItem)
$traitGrid.AddChild($traitUIElements.selectItem)

$traitUIElements.addItem.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
$traitUIElements.selectItem.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
$traitUIElements.removeItem.SetValue([Windows.Controls.Grid]::ColumnProperty,2)

$traitUIElements.selectItem.ItemsSource = $traitList

$traitUIElements.addItem.Add_Click(
    {
        addCombobox
        # Add a row to the grid
        # Move both buttons down to the new row
        # Create a new combobox
        # Set the coordinates for the combobox
        # Add new combobox to the grid
        # Add the selection_changed handler
    }
)

$traitUIElements.removeItem.Add_Click(
    {
        [System.Windows.MessageBox]::Show("Remove button clicked")
    }
)

$traitUIElements.selectItem.Add_SelectionChanged(
    {
        [System.Windows.MessageBox]::Show("Selection made")
    }
)

$window.ShowDialog() | Out-Null