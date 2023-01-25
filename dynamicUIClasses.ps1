Add-Type -AssemblyName PresentationFramework

$windowPropertySet = @{
    "Type"  = "Windows.Window"
    "Height" = "768"
    "Width" = "1024"
    "Title" = "Crimson Reign Character Builder"
    "WindowStartupLocation" ="CenterScreen"    
}

$addButtonPropertySet = @{
    "Type"="System.Windows.Controls.Button"
    "Name"="AddTrait"
    "Content"="+"
    "Height"=30
    "Width"=30
}

$removeButtonPropertySet = @{
    "Type"="System.Windows.Controls.Button"
    "Name"="RemoveTrait"
    "Content"="-"
    "Height"=30
    "Width"=30
}

$traitComboBoxPropertySet = @{
    "Type"="System.Windows.Controls.ComboBox"
    "Name"="TraitValue"
    "Height"=30
    "Width"=150
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

function createUIElement([hashtable] $propertySet)
{
    $UIcontrol = New-Object $($propertySet.Type)
    $objectType = $propertySet.Type
    $propertySet.Remove("Type")
    $propertySet.Keys | ForEach-Object { $UIcontrol.$_ = $propertySet.$_ }
    $propertySet.Add("Type",$objectType)

    return $UIcontrol
}

function addMultiControl([hashtable]$addButtonPropertySet, [hashtable]$removeButtonPropertySet, [hashtable]$traitComboBoxPropertySet, $parentControl)
{

    # see if I can make a copy of an existing control instead creating a new object
    
    if ($null -eq $parentControl -and $traitRowCount -gt 0)
    {
        $parentControl = $controlSet[0].RemoveTrait.Parent         # get the parent from the first UI control
    }
    $removeButton = createUIElement $removeButtonPropertySet
    $addButton    = createUIElement $addButtonPropertySet
    $comboBox     = createUIElement $traitComboBoxPropertySet

    [hashtable] $multiControl = [ordered]@{}
    $multiControl.Add("AddTrait", $addButton)
    $multiControl.Add("RemoveTrait", $removeButton)
    $multiControl.Add("SelectTrait", $comboBox)

    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = 40 
    $parentControl.RowDefinitions.Add($row)

    $multiControl.AddTrait.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
    $multiControl.SelectTrait.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
    $multiControl.RemoveTrait.SetValue([Windows.Controls.Grid]::ColumnProperty,2)

    $multiControl.AddTrait.SetValue([Windows.Controls.Grid]::RowProperty,$traitRowCount)
    $multiControl.SelectTrait.SetValue([Windows.Controls.Grid]::RowProperty,$traitRowCount)
    $multiControl.RemoveTrait.SetValue([Windows.Controls.Grid]::RowProperty,$traitRowCount)

    $controlSet.Add($multiControl) | Out-Null

    if ($traitRowCount -eq 0)
    {
        $controlSet[0].RemoveTrait.Visibility = "Hidden"
    }
    else {
        $controlSet[$traitRowCount-1].RemoveTrait.Visibility = "Hidden"
        $controlSet[$traitRowCount-1].AddTrait.Visibility = "Hidden"
    }

    $parentControl.AddChild($multiControl.AddTrait)
    $parentControl.AddChild($multiControl.RemoveTrait)
    $parentControl.AddChild($multiControl.SelectTrait)

    $controlSet[$traitRowCount].AddTrait.Add_Click(
        {
            addMultiControl $addButtonPropertySet $removeButtonPropertySet $traitComboBoxPropertySet $parentControl
        }
    )

    $global:traitRowCount++

}

function removeMultiControl($parentControl)
{
    # remove the controls from the parent control first
    # remove the controlset from the array list
    # update the visibility of the buttons

    $parentControl.Remove($multiControl.AddTrait)



}

### Main Program ####

$window = createUIElement $windowPropertySet
$grid = New-Object Windows.Controls.Grid
$grid.Name = "TraitGrid"

$traitRowCount = 0
$controlSet = [System.Collections.ArrayList]@()

InitializeGrid $window $grid

$window.Content = $grid

# Call this once for the first row
addMultiControl $addButtonPropertySet $removeButtonPropertySet $traitComboBoxPropertySet $grid

$window.ShowDialog() | Out-Null