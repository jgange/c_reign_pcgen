add-Type -AssemblyName PresentationFramework

[xml]$Form = @"
    <Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="My First Form" Height="800" Width="600">
    <StackPanel Name="StackPanel1" Width="300" Height="200" Background="LightBlue" Orientation="Horizontal">
    <Button Name="MyButton" Width="120" Height="85" Content='Hello' />
    <Button Name="MyButton2" Width="120" Height="85" Content='Hello2' />
    </StackPanel>
    </Window>
"@

$nodeReader = (New-Object System.Xml.XmlNodeReader $Form)
$newWindow = [Windows.Markup.XamlReader]::Load($nodeReader)

$newWindow.ShowDialog()