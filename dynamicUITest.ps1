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
        <StackPanel x:Name="StackPanelLeft" HorizontalAlignment="Left" Height="400" Margin="20,0,0,0" VerticalAlignment="Top" Width="30">
            <StackPanel.Resources>
                <Style TargetType="{x:Type Button}">
                    <Setter Property="Margin" Value="0,5,0,0"/>
                </Style>
            </StackPanel.Resources> 
        </StackPanel>

        <StackPanel x:Name="StackPanelMiddle" HorizontalAlignment="Left" Height="400" Margin="20,0,0,0" VerticalAlignment="Top" Width="200">
            <StackPanel.Resources>
                <Style TargetType="{x:Type Button}">
                    <Setter Property="Margin" Value="0,5,0,0"/>
                </Style>
            </StackPanel.Resources> 
        </StackPanel>

        <StackPanel x:Name="StackPanelRight" HorizontalAlignment="Left" Height="400" Margin="200,20,0,0" VerticalAlignment="Top" Width="30">
            <StackPanel.Resources>
                <Style TargetType="{x:Type Button}">
                    <Setter Property="Margin" Value="0,5,0,0"/>
                </Style>
            </StackPanel.Resources> 
        </StackPanel>

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
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$XAML.SelectNodes("//*[@Name]") |
ForEach-Object {
    Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)
}

$PlusButton1 = New-Object System.Windows.Controls.Button
$PlusButton1.Height = 20
$PlusButton1.Width = 20
$PlusButton1.FontSize = 16
$PlusButton1.FontWeight = "Bold"
$PlusButton1.HorizontalAlignment = "Center"
$PlusButton1.VerticalAlignment = "Center"
$PlusButton1.Padding = "0,-4,0,0"
$PlusButton1.Content = " + "
$WPFStackPanelLeft.AddChild($PlusButton1)

$PlusButton2 = New-Object System.Windows.Controls.Button
$PlusButton2.Height = 20
$PlusButton2.Width = 20
$PlusButton2.FontSize = 16
$PlusButton2.FontWeight = "Bold"
$PlusButton2.HorizontalAlignment = "Center"
$PlusButton2.VerticalAlignment = "Center"
$PlusButton2.Padding = "0,-4,0,0"
$PlusButton2.Content = " + "

$PlusButton3 = New-Object System.Windows.Controls.Button
$PlusButton3.Height = 20
$PlusButton3.Width = 20
$PlusButton3.FontSize = 16
$PlusButton3.FontWeight = "Bold"
$PlusButton3.HorizontalAlignment = "Center"
$PlusButton3.VerticalAlignment = "Center"
$PlusButton3.Padding = "0,-4,0,0"
$PlusButton3.Content = " + "

$MinusButton2 = New-Object System.Windows.Controls.Button
$MinusButton2.Height = 20
$MinusButton2.Width = 20
$MinusButton2.FontSize = 16
$MinusButton2.FontWeight = "Bold"
$MinusButton2.HorizontalAlignment = "Center"
$MinusButton2.VerticalAlignment = "Center"
$MinusButton2.Padding = "0,-4,0,0"
$MinusButton2.Margin = "6,10,0,0"
$MinusButton2.Content = " - "

$MinusButton3 = New-Object System.Windows.Controls.Button
$MinusButton3.Height = 20
$MinusButton3.Width = 20
$MinusButton3.FontSize = 16
$MinusButton3.FontWeight = "Bold"
$MinusButton3.HorizontalAlignment = "Center"
$MinusButton3.VerticalAlignment = "Center"
$MinusButton3.Padding = "0,-4,0,0"
$MinusButton3.Margin = "6,5,0,0"
$MinusButton3.Content = " - "

$TextBox1 = New-Object System.Windows.Controls.TextBox
$TextBox1.FontSize = 14
$TextBox1.Height = 20
$TextBox1.Width = 140
$TextBox1.HorizontalAlignment = "Center"
$TextBox1.VerticalAlignment = "Center"
$TextBox1.Margin = "12,5,0,0"
$TextBox1.Text = "Talent 1"
$WPFStackPanelMiddle.AddChild($TextBox1)

$TextBox2 = New-Object System.Windows.Controls.TextBox
$TextBox2.FontSize = 14
$TextBox2.Height = 20
$TextBox2.Width = 140
$TextBox2.HorizontalAlignment = "Center"
$TextBox2.VerticalAlignment = "Center"
$TextBox2.Margin = "12,5,0,0"
$TextBox2.Text = "Talent 2"

$TextBox3 = New-Object System.Windows.Controls.TextBox
$TextBox3.FontSize = 14
$TextBox3.Height = 20
$TextBox3.Width = 140
$TextBox3.HorizontalAlignment = "Center"
$TextBox3.VerticalAlignment = "Center"
$TextBox3.Margin = "12,5,0,0"
$TextBox3.Text = "Talent 3"

$PlusButton1.Add_Click(
    {
        $WPFStackPanelLeft.AddChild($PlusButton2)
        $WPFStackPanelMiddle.AddChild($TextBox2)
        $WPFStackPanelRight.AddChild($MinusButton2)
    }
)

$MinusButton2.Add_Click(
    {
        $WPFStackPanelLeft.Children.Remove($PlusButton2)
        $WPFStackPanelMiddle.Children.Remove($TextBox2)
        $WPFStackPanelRight.Children.Remove($MinusButton2)
    }
)

$MinusButton3.Add_Click(
    {
        $WPFStackPanelLeft.Children.Remove($PlusButton3)
        $WPFStackPanelMiddle.Children.Remove($TextBox3)
        $WPFStackPanelRight.Children.Remove($MinusButton3)
        $MinusButton2.Visibility = "Visible"
    }
)

$PlusButton2.Add_Click(
    {
        $WPFStackPanelLeft.AddChild($PlusButton3)
        $WPFStackPanelMiddle.AddChild($TextBox3)
        $WPFStackPanelRight.AddChild($MinusButton3)
        $MinusButton2.Visibility = "Hidden"
    }
)

$Form.ShowDialog() | Out-Null