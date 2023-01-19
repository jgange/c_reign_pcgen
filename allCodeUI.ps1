# Add required assembly
Add-Type -AssemblyName PresentationFramework
 
# Create a Window
$Window = New-Object Windows.Window
$Window.Height = "670"
$Window.Width = "700"
$Window.Title = "PowerShell WPF Window"
$window.WindowStartupLocation="CenterScreen"
 
# Create a grid container with 2 rows, one for the buttons, one for the datagrid
$Grid =  New-Object Windows.Controls.Grid
$Row1 = New-Object Windows.Controls.RowDefinition
$Row2 = New-Object Windows.Controls.RowDefinition
$Row1.Height = "70"
$Row2.Height = "100*"
$Grid.RowDefinitions.Add($Row1)
$Grid.RowDefinitions.Add($Row2)
 
# Create a button to get running Processes
$Button_Processes = New-Object Windows.Controls.Button
$Button_Processes.SetValue([Windows.Controls.Grid]::RowProperty,0)
$Button_Processes.Height = "50"
$Button_Processes.Width = "150"
$Button_Processes.Margin = "10,10,10,10"
$Button_Processes.HorizontalAlignment = "Left"
$Button_Processes.VerticalAlignment = "Top"
$Button_Processes.Content = "Get Processes"
$Button_Processes.Background = "Aquamarine"
 
# Create a button to get services
$Button_Services = New-Object Windows.Controls.Button
$Button_Services.SetValue([Windows.Controls.Grid]::RowProperty,0)
$Button_Services.Height = "50"
$Button_Services.Width = "150"
$Button_Services.Margin = "180,10,10,10"
$Button_Services.HorizontalAlignment = "Left"
$Button_Services.VerticalAlignment = "Top"
$Button_Services.Content = "Get Services"
$Button_Services.Background = "Aquamarine"
 
# Create a button to play Click the fruit
$Button_Cool = New-Object Windows.Controls.Button
$Button_Cool.SetValue([Windows.Controls.Grid]::RowProperty,0)
$Button_Cool.Height = "50"
$Button_Cool.Width = "150"
$Button_Cool.Margin = "350,10,10,10"
$Button_Cool.HorizontalAlignment = "Left"
$Button_Cool.VerticalAlignment = "Top"
$Button_Cool.Content = "Play 'Click the Fruit'"
$Button_Cool.Background = "Aquamarine"
 
# Create a datagrid
$DataGrid = New-Object Windows.Controls.DataGrid
$DataGrid.SetValue([Windows.Controls.Grid]::RowProperty,1)
$DataGrid.MinHeight = "100"
$DataGrid.MinWidth = "100"
$DataGrid.Margin = "10,0,10,10"
$DataGrid.HorizontalAlignment = "Stretch"
$DataGrid.VerticalAlignment = "Stretch"
$DataGrid.VerticalScrollBarVisibility = "Auto"
$DataGrid.GridLinesVisibility = "none"
$DataGrid.IsReadOnly = $true
 
# Add the elements to the relevant parent control
$Grid.AddChild($DataGrid)
$Grid.AddChild($Button_Processes)
$Grid.AddChild($Button_Services)
$Grid.AddChild($Button_Cool)
$window.Content = $Grid
 
# Add an event on the Get Processes button
$Button_Processes.Add_Click({
    $Processes = Get-Process | Select ProcessName,HandleCount,NonpagedSystemMemorySize,PrivateMemorySize,WorkingSet,UserProcessorTime,Id
    $DataGrid.ItemsSource = $Processes
    })
 
# Add an event on the Get Services button
$Button_Services.Add_Click({
    $Services = Get-Service | Select Name,ServiceName,Status,StartType
    $DataGrid.ItemsSource = $Services
    })
 
# Add an event to play Click the fruit
$Button_Cool.Add_Click({
 
    $Fruit = @{
        Apples = "Green"
        Bananas = "Yellow"
        Oranges = "Orange"
        Plums = "Maroon"
    }
 
    $Fruit.GetEnumerator() | Foreach {
        # Create a transparent window at a random location on the screen
        $NewWindow = New-Object Windows.Window
        $NewWindow.SizeToContent = "WidthAndHeight"
        $NewWindow.AllowsTransparency = $true
        $NewWindow.WindowStyle = "none"
        $NewWindow.Background = "Transparent"
        $NewWindow.WindowStartupLocation = "Manual"
        $Height = Get-Random -Maximum (([System.Windows.SystemParameters]::PrimaryScreenHeight) - 100)
        $Width = Get-Random -Maximum (([System.Windows.SystemParameters]::PrimaryScreenWidth) - 100)
        $NewWindow.Left = $Width
        $NewWindow.Top = $Height
 
        # Add a label control for the fruit
        $NewLabel = New-Object Windows.Controls.Label
        $NewLabel.Height = "150"
        $NewLabel.Width = "400"
        $NewLabel.Content = $_.Name
        $NewLabel.FontSize = "100"
        $NewLabel.FontWeight = "Bold"
        $NewLabel.Foreground = $_.Value
        $NewLabel.Background = "Transparent"
        $NewLabel.Opacity = "100"
 
        # Add an event to close the window when clicked
        $NewWindow.Add_MouseDown({
            $This.Close()
        })
 
        # Add an event to change the cursor to a hand when the mouse goes over the window
        $NewWindow.Add_MouseEnter({
        $this.Cursor = "Hand"
        })
 
        # Display the window
        $NewWindow.Content = $NewLabel
        $NewWindow.ShowDialog()
    }
})
 
# Show the window
if (!$psISE)
{
    # Hide PS console window
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0) 
 
    # Run as an application in it's own context
    $app = [Windows.Application]::new()
    $app.Run($Window)
}
Else
{
    [void]$window.ShowDialog()
}