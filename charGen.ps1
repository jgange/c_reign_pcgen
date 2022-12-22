#### INITIALIZATION ####

$dataStoreLocation  = "C:\Users\joega\Projects\PowerShell\c_reign_pcgen"
$raceFile           = "races.json"
$buildsFile         = "builds.json"
$traitsFile         = "traits.json"
$systemRulesFile    = "systemRules.json"
$buildCostsFile     = "buildPointCost.json"
$attributeTableFile = "attributesTable.json"

#### METHODS ####

function populateData($filePath)
{
    return Get-Content -Path $filePath | ConvertFrom-Json
}

function returnRecordSet($records, $propertyName, $value)
{
    $records | Where-Object {$_.$propertyName -eq $value}
}

#### MAIN PROGRAM ####

$buildType = "Heroic"
$race      = "Draikosi"

$raceTable       = populateData ($dataStoreLocation, $raceFile -join "\") 
$characterBuilds = populateData ($dataStoreLocation, $buildsFile -join "\") 
$traitTable      = populateData ($dataStoreLocation, $traitsFile -join "\")
$systemRules     = populateData ($dataStoreLocation, $systemRulesFile -join "\")
$buildPointCosts = populateData ($dataStoreLocation, $buildCostsFile -join "\")
$attributeTable  = populateData ($dataStoreLocation, $attributeTableFile -join "\")

$raceInfo  = returnRecordSet $raceTable "RaceName" $race
$buildInfo = returnRecordSet $characterBuilds "BuildType" $buildType

$raceInfo
$buildInfo
$traitTable
$systemRules
$buildPointCosts
$attributeTable