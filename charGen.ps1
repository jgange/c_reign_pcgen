#### INITIALIZATION ####

$dataStoreLocation   = "C:\Users\joega\Projects\PowerShell\c_reign_pcgen"
$raceFile            = "races.json"
$buildsFile          = "builds.json"
$traitsFile          = "traits.json"
$systemRulesFile     = "systemRules.json"
$buildCostsFile      = "buildPointCost.json"
$attributeTableFile  = "attributesTable.json"
$professionTiersFile = "professionTiers.json"
$characterBuildFile      = "brak.json"

#### METHODS ####

function populateData($filePath)
{
    return Get-Content -Path $filePath | ConvertFrom-Json
}

function returnRecordSet($records, $propertyName, $value)
{
    $records | Where-Object {$_.$propertyName -eq $value}
}

function writeDescription([string] $key, [string] $value)
{
    Write-Output "$key = $value"
}

function calculateBuildCost($characterBuild, $professionTiers)
{
    # Extract items that have a build cost

    $Tiers = ($professionTiers.Tier | Get-Member -MemberType NoteProperty).Name | ForEach-Object { $professionTiers.Tier.$_  }
    # $Tiers | ForEach-Object { $_.SkillRank }

    if ($characterBuild.Backgrounds)
    {
        for($i=0;$i -lt $characterBuild.Backgrounds.Count; $i++)
        {
            $background = ($characterBuild.Backgrounds[$i] | Get-Member -MemberType NoteProperty).Name
            $backgroundTier = [int] $characterBuild.Backgrounds[$i].$background
            $backgroundTier
            $Tiers | ForEach-Object {
                if ($backgroundTier -eq $_.SkillRank) {$_.buildPointCost}
            }  
        }
    }
}

#### MAIN PROGRAM ####

$buildType = "Heroic"
$race      = "Draikosi"

$raceTable       = populateData ($dataStoreLocation, $raceFile -join "\") 
$characterBuild = populateData ($dataStoreLocation, $buildsFile -join "\") 
$traitTable      = populateData ($dataStoreLocation, $traitsFile -join "\")
$systemRules     = populateData ($dataStoreLocation, $systemRulesFile -join "\")
$buildPointCosts = populateData ($dataStoreLocation, $buildCostsFile -join "\")
$attributeTable  = populateData ($dataStoreLocation, $attributeTableFile -join "\")
$professionTiers = populateData ($dataStoreLocation, $professionTiersFile -join "\")
$characterBuild  = populateData ($dataStoreLocation, $characterBuildFile -join "\")

$raceInfo  = returnRecordSet $raceTable "RaceName" $race
$buildInfo = returnRecordSet $characterBuild "BuildType" $buildType

#$raceInfo
#$buildInfo
#$traitTable
#$systemRules
#$buildPointCosts
#$attributeTable
#$characterBuild
#$professionTiers

calculateBuildCost $characterBuild $professionTiers