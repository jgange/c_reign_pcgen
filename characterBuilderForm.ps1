Add-Type -AssemblyName PresentationFramework

$displayFormFilePath = "C:\Users\joega\Projects\PowerShell\c_reign_pcgen\characterBuildForm.xaml"

[xml]$xaml = Get-Content $displayFormFilePath

#$xaml

$Reader = (New-Object System.Xml.XmlNodeReader $xaml)
$characterBuildFormWindow = [Windows.Markup.XamlReader]::Load($Reader)

$characterBuildFormWindow.ShowDialog()