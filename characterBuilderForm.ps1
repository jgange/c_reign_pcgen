Add-Type -AssemblyName PresentationFramework

$displayFormFilePath = $PSScriptRoot, "characterBuildForm.xaml" -join "\"

[xml]$xaml = Get-Content $displayFormFilePath

#$xaml

$Reader = (New-Object System.Xml.XmlNodeReader $xaml)
$characterBuildFormWindow = [Windows.Markup.XamlReader]::Load($Reader)

$playerName = $characterBuildFormWindow.FindName("playerNameValue")
$characterName = $characterBuildFormWindow.FindName("characterNameValue")
$characterBuild = $characterBuildFormWindow.FindName("buildSelector")
$characterBuildPoints = $characterBuildFormWindow.FindName("buildPoints")

$playerName.Text
$characterName.Text
$characterBuild.Text
$characterBuildPoints.Text

$characterBuildFormWindow.ShowDialog()