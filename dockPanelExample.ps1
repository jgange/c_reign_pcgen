Add-Type –assemblyName PresentationFramework

[xml]$XAML = @'
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="MenuIconCheckableSample" Height="150" Width="300">
    <Grid> 
    <DockPanel LastChildFill = "True"> 
        <Button Content = "Top" DockPanel.Dock = "Top"/> 
        <Button Content = "Bottom" DockPanel.Dock = "Bottom" />
        <Button Content = "Left"/> 
        <Button Content = "Right" DockPanel.Dock = "Right"/> 
        <Button Content = "Center"/> 
    </DockPanel> 
    </Grid> 
</Window> 
'@

$Reader = New-Object System.Xml.XmlNodeReader $XAML
$Form = [Windows.Markup.XamlReader]::Load( $Reader )

$Form.ShowDialog() | out-null