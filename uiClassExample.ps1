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

$traitTextBoxPropertySet = @{
    "Type"="TextBox"
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

[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[xml]$XAML = $RawXAML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

#Read XAML 
$XAMLReader= New-Object System.Xml.XmlNodeReader $XAML
try{
    $Form=[Windows.Markup.XamlReader]::Load($XAMLReader)
} catch {
    Throw "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
}

$XAML.SelectNodes("//*[@Name]") |
ForEach-Object {
    Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -Scope global
}

# Main

class MultiControl
{
    $addEntryControl
    $dataValuesControl
    $removeEntryControl
    
    [int] $position

    MultiControl($addControl, $removeControl, $dataControl)
    {
        $this.addEntryControl = $addControl
        $this.dataValuesControl = $dataControl
        $this.removeEntryControl = $removeControl
        $this.position = 0
    }

    [void] AddMultiControl($parent)
    {
        # Adds a new multicontrol
        # this should 
        $parent.AddChild($this.addEntryControl)
        $parent.AddChild($this.dataControl)
    }

    [void] RemoveMultiControl()
    {
        # Removes a multicontrol
    }

    [void] AlignMultiControl([System.Windows.Controls.ContentControl]$mc1, [System.Windows.Controls.ContentControl]$mc2, [System.Windows.Controls.ContentControl]$mc3)
    {
        # Gets a list of controls and vertically aligns them
    }

}

$traitRemoveBtn = createUIControl $removeButtonPropertySet
$traitAddBtn = createUIControl $addButtonPropertySet
$traitTextBox = createUIControl $traitTextBoxPropertySet

[MultiControl]$m1 = [MultiControl]::new($traitAddBtn, $traitRemoveBtn, $traitTextBox)
$m1.addEntryControl.Name
$m1.removeEntryControl.Name
$m1.dataValuesControl.Name

$m1.AddMultiControl($WPFLayoutRoot)