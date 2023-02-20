# $elements = [System.Collections.ArrayList]@()

$componentFile = "./UIComponents.json"
$screenlayoutFile = "./Screenlayout.json"

$elements = Get-Content -Path $componentFile | ConvertFrom-Json
$screenLayout = Get-Content -Path $screenlayoutFile

$elements | Format-List
$screenlayout | Format-List

