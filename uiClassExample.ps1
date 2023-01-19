<#
Want to be able to pass in a set of properties for the object to create the control

these controls get aggregated into a multicontrol

are the properties for the multicontrol the property set for each control?

I need to know which control was clicked so I can properly execute UI and backend processes

Example #1 I clicked on the Add control in Row 2 of my trait section
Example #2 I clicked on the Remove control in Row 1 of my backgrounds section

Example #1 has to be handled in my Add_Click method for the button clicked
That Add_Click method is has to know about the other controls and also what other procedures to call

If I create a multicontrol and the AddControl method creates a new set of controls, I need to also
include the Add_SelectionChanged on the text element which knows what function to call to update the build points properly

Could include a Case statement inside the SelectionChanged method which figures out which function to call depending on the contents

multicontrol

Combobox    Traits			    -> 0 or more
Comboxbox   Backgrounds		    -> 1 to 3
Comboxbox   Additional Skills	-> 0 or more
Combobox    Racial Abilities	-> 1 or more if race has them
Combobox    Spells			    -> 0 or more only if Awakened (or other spell casting trait)
Comboxbox   Equipment		    -> Starting

Skills from Background are separate even though they are skills (elements should be marked read only)

Create a generate multicontrol then inherit then specific method
So, base class is a generic multicontrol
Then sub-class for each specific type where each type has a method associated for build points on the data entry element
This would also allow me to customize behaviors or properties for each type and not have to store a type on it
Very few properties would also have to be set but a default could be set on the base class

the properties are simply a pointer to the actual control so I can address it with objectname.UIControlname or something

The only properties are the actual controls included - the sub-properties to create the UIcontrol are passed into the constructor but not saved as part of the class object

Each sub-class has a specific set of rules associated around # of allowed elements
#>

$RawXAML = @"
<Window x:Class="WpfApplication3.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication3"
        mc:Ignorable="d"
        Title="MainWindow" Width="1024" Height="768" ResizeMode="NoResize">
        <Grid x:Name="LayoutRoot" VerticalAlignment="Center" Width="1280" Height="1024">
        </Grid>
</Window>
"@ 
 
$addButtonPropertySet = @{
    "Type"="Button"
    "Name"="AddTrait"
    "Content"="+"
    "Height"=30
    "Width"=30
    "Margin"="10,10,10,10"
}

$removeButtonPropertySet = @{
    "Type"="Button"
    "Name"="RemoveTrait"
    "Content"="-"
    "Height"=30
    "Width"=30
    "Margin"="10,10,10,10"
}

$traitComboBoxPropertySet = @{
    "Type"="ComboBox"
    "Name"="TraitValue"
    "Height"=30
    "Width"=150
    "Margin"="10,10,10,10"
}

### Functions ########

function createUIControl([hashtable] $propertySet)
{
    $UIcontrol = New-Object $("System.Windows.Controls." + $propertySet.Type)
    $propertySet.Remove("Type")
    $propertySet.Keys | ForEach-Object { $UIcontrol.$_ = $propertySet.$_ }

    return $UIcontrol
}

### Main Program #####

# Create a Window
$Form = New-Object Windows.Window
$Form.Height = "670"
$Form.Width = "700"
$Form.Title = "PowerShell WPF Window"
$Form.WindowStartupLocation="CenterScreen"

$Grid =  New-Object Windows.Controls.Grid
$Row = New-Object Windows.Controls.RowDefinition
$Row.Height = "*"
$Grid.RowDefinitions.Add($Row)

$Col = New-Object Windows.Controls.ColumnDefinition
$Grid.ColumnDefinitions.Add($Col)

class MultiControl
{
    $addEntryControl
    $dataValuesControl
    $removeEntryControl
    
    MultiControl($addControl, $removeControl, $dataControl)
    {      
        $this.addEntryControl = $addControl
        $this.dataValuesControl = $dataControl
        $this.removeEntryControl = $removeControl
    }
}

class MultiControlSet
{
    # This class manages the entire set of multicontrols

    $controlSet = [System.Collections.ArrayList]@()

    MultiControlSet($multiControl, $parent)
    {
        $this.controlSet.Add($multiControl)
        $this.InitializeGrid($parent)

        $parent.AddChild($multiControl.addEntryControl)
        $parent.AddChild($multiControl.dataValuesControl)
        $parent.AddChild($multiControl.removeEntryControl)

        [System.Windows.Controls.Grid]::SetColumn($multiControl.addEntryControl,0)
        [System.Windows.Controls.Grid]::SetColumn($multiControl.dataValuesControl,1)

        [System.Windows.Controls.Grid]::SetRow($multiControl.addEntryControl,0)
        [System.Windows.Controls.Grid]::SetRow($multiControl.dataValuesControl,0)
    }

    InitializeGrid($parent)
    {
        $row = new-object system.windows.controls.rowdefinition
        $row.height = "Auto"
        $parent.RowDefinitions.add($row)
        
        for($i=0;$i -lt 3; $i++)
        {
            $col = new-object system.windows.controls.columndefinition
            $col.width = "Auto"
            $parent.ColumnDefinitions.add($col)
        }   
    }
}

$traitRemoveBtn = createUIControl $removeButtonPropertySet
$traitAddBtn    = createUIControl $addButtonPropertySet
$traitComboBox  = createUIControl $traitComboBoxPropertySet

# set up the starting state of the grid: 3 col x 1 row

[MultiControl]$m1 = [MultiControl]::new($traitAddBtn, $traitRemoveBtn, $traitComboBox)
$m1
[MultiControlSet]$mc = [MultiControlSet]::new($m1, $WPFLayoutRoot)
$mc

$WPFLayoutRoot.ShowGridLines = $true

$Form.ShowDialog() | Out-Null