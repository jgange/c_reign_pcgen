Add-Type –assemblyName PresentationFramework

[xml]$XAML = @'
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MenuIconCheckableSample" Height="150" Width="300">
    <DockPanel>
        <Menu DockPanel.Dock="Top">
            <MenuItem Header="_File">
                <MenuItem Header="_Exit" />
            </MenuItem>
            <MenuItem Header="_Tools">
                <MenuItem Header="_Manage users">
                </MenuItem>
                <MenuItem Header="_Show groups" IsCheckable="True" IsChecked="True" />
            </MenuItem>
        </Menu>
        <TextBox AcceptsReturn="True" />
    </DockPanel>
</Window>
'@
$Reader = New-Object System.Xml.XmlNodeReader $XAML
$Form = [Windows.Markup.XamlReader]::Load( $Reader )

$Form.ShowDialog() | out-null
