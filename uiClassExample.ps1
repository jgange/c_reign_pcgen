$RawXAML = @"
<Window x:Class="WpfApplication3.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication3"
        mc:Ignorable="d"
        Title="MainWindow" Width="1024" Height="768" ResizeMode="NoResize">
        <Grid>
        <Label x:Name="FirstLbl" Content="Label One" Width="100" HorizontalAlignment="Left"/>
        <Label x:Name="SecondLbl" Content="Label Two" Width="100" HorizontalAlignment="Left"/>
        </Grid>
</Window>
"@ 
 
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

class multiControl
{
    [System.Windows.Controls.ContentControl[]]$childControls
    [System.Collections.Specialized.OrderedDictionary]$propertyList
    [System.Windows.Controls.ContentControl]$parentControl


}

