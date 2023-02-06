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
    "Traits"      = [System.Collections.ArrayList]@("","Affinity","Alert","Arrogant","Brash","Captivating")
    "Backgrounds" = [System.Collections.ArrayList]@("","Apothecary","Craftsman","Merchant")
}
$choices = @{
	"Traits" = [System.Collections.ArrayList]@()
	"Backgrounds" = [System.Collections.ArrayList]@()
}
$pointCosts = @{
    "Affinity"=30
    "Alert"=30
    "Arrogant"=-15
    "Brash"=15
    "Captivating"=30
    "Apothecary"=10
    "Craftsman"=10
    "Merchant"=10
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

        $multiControls.$element.removeItem.Visibility = "Hidden"                # Can't remove until a row has been added
        $multiControls.$element.AddItem.Visibility = "Hidden"                   # Can't add until a selection is made
    
        $gridInstance.AddChild($multiControls.$element.addItem)
        $gridInstance.AddChild($multiControls.$element.removeItem)
        $gridInstance.AddChild($multiControls.$element.selectItem)
    
        $multiControls.$element.addItem.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
        $multiControls.$element.selectItem.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
        $multiControls.$element.removeItem.SetValue([Windows.Controls.Grid]::ColumnProperty,2)
    
        $multiControls.$element.selectItem.ItemsSource = $dataSet.$element
    
        $multiControls.$element.addItem.Add_Click({ addCombobox $ComboBoxPropertySet })
        $multiControls.$element.removeItem.Add_Click({ removeCombobox })
        $multiControls.$element.selectItem.Add_SelectionChanged({ updateControl })   
    }
    
}

function addCombobox($ComboBoxPropertySet)
{   
    # buttons should probably have tooltips to explain their behavior

    $elementName = $this.Parent.Name
    $grid = $this.Parent
    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = $textHeight
    $grid.RowDefinitions.Add($row)

    $multiControls.$elementName.rowCount++
    $multiControls.$elementName.addItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.Visibility = "visible"
    $multiControls.$elementName.addItem.Visibility = "hidden"

    $newComboBox = createUIElement $ComboBoxPropertySet
    $newComboBox.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $newComboBox.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
    $newComboBox.ItemsSource = $dataSet.$elementName
    $newComboBox.Add_SelectionChanged({ updateControl })

    $multiControls.$elementName.controlSet.Add($newComboBox)
    $grid.AddChild($newComboBox)

}

function removeCombobox()
{
    $elementName = $this.Parent.Name
    $grid = $this.Parent
    $rc = $multiControls.$elementName.rowCount - 1
    #$selectedItem = $this.selectedValue  # This is wrong, it will pick up the button not the associated combobox value
    # I need the value of the controlset on the current row and get the selected value from there

    #[System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.rowCount)
    # I think this is related to delays in removing the UI element - try introducing a short delay
    $selectedItem = $multiControls.$elementName.controlSet[$rc].selectedValue

    [System.Windows.MessageBox]::Show($selectedItem)
    $choices.$elementName.Remove($selectedItem)
    $dataSet.$elementName.Add($selectedItem)

    $multiControls.$elementName.rowCount--
    $currentComboBox = $multiControls.$elementName.controlSet[$multiControls.$elementName.rowCount]
    [System.Windows.MessageBox]::Show($elementName + " " + $multiControls.$elementName.controlSet.Count)
    
    $grid.Children.Remove($currentComboBox)

    if ($multiControls.$elementName.rowCount -eq 0) 
    {
        $multiControls.$elementName.removeItem.Visibility="hidden"
    }

    $multiControls.$elementName.AddItem.Visibility = "visible"

    $multiControls.$elementName.addItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)
    $multiControls.$elementName.removeItem.SetValue([Windows.Controls.Grid]::RowProperty,$multiControls.$elementName.rowCount)

    $multiControls.$elementName.controlSet.Remove($currentComboBox)

}


function updateControl()
{
    # if the user selects a blank or a new combobox is generated, the add button should be hidden
    $elementName = $this.Parent.Name
    $selectedItem = $this.selectedValue
    if ($selectedItem -eq "")
    {
        $multiControls.$elementName.addItem.Visibility = "hidden"
        # if they have deleted all the items and select blank for the last item, remove the last item
        if ($multiControls.$elementName.rowCount -eq 0) { 
            $lastItem = $choices.$elementName[0]
            $choices.$elementName.Remove($lastItem)
        }
    }
    else {
        $choices.$elementName.Add($selectedItem)
        $dataSet.$elementName.Remove($selectedItem)
        $multiControls.$elementName.addItem.Visibility = "visible"
    }  
    updateBuildPoints $elementName $selectedItem
}
function updateBuildPoints([string] $elementName, [string] $selectedItem)
{
    # actually does the calculations
    $buildPointCost = $pointCosts.$selectedItem
    [System.Windows.MessageBox]::Show("Selected " + $selectedItem + " for " + $elementName + " which costs " + $buildPointCost)

}


### Main Program ###

$window = createUIElement $windowPropertySet
$masterGrid = New-Object Windows.Controls.Grid
$window.Content = $masterGrid
$multiControls = @{}

buildGrids       $elementList
createControlSet $elementList
placeControls    $elementList

$Window.Add_Closing(
    {
        Write-Host "Closing Window"
        $choices | Out-File "./choices.txt" -Force
    }
)

$window.ShowDialog() | Out-Null