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

function computeBackgroundCost($characterBuild, $professionTiers)
{
    [int] $bp = 0
    $Tiers = ($professionTiers.Tier | Get-Member -MemberType NoteProperty).Name | ForEach-Object { $professionTiers.Tier.$_  }

    if ($characterBuild.Backgrounds)
    {
        for($i=0;$i -lt $characterBuild.Backgrounds.Count; $i++)
        {
            $background = ($characterBuild.Backgrounds[$i] | Get-Member -MemberType NoteProperty).Name
            $backgroundTier = [int] $characterBuild.Backgrounds[$i].$background
            $Tiers | ForEach-Object {
                if ($backgroundTier -eq $_.SkillRank) {$bp += [int]$_.buildPointCost}
            }  
        }
    }
    return [int] $bp
}

function computeSkillsCost($characterBuild, $buildPointCosts)
{
    $skillList = ($characterBuild.Skills | Get-Member -MemberType NoteProperty).Name
    $skillCost = $buildPointCosts.Skill

    $skillList | ForEach-Object { $bps+= $skillCost}
    $bps
}
function calculateBuildCost($characterBuild, $professionTiers, $buildPointCosts)
{
    # Extract items that have a build cost
    computeBackgroundCost $characterBuild $professionTiers
    computeSkillsCost $characterBuild $buildPointCosts
    computeAttributesCost $characterBuild $raceTable

}

function computeAttributesCost($characterBuild, $raceTable)
{
    $characterRace = $characterBuild.Race
    $attributes = $characterBuild.Attributes
    $attributes
    for($i=0;$i -lt $raceTable.Count; $i++)
    {
        if ($raceTable.RaceName[$i] -eq [string]$characterRace)
        {
            $attributeList = ($raceTable[$i].BaseAttributes | Get-Member -MemberType NoteProperty).Name
            $attributeList | ForEach-Object {         
                writeDescription "Base racial attribute value" $raceTable[$i].BaseAttributes.$_
                writeDescription "Actual attribute value" $characterBuild.Attributes.$_
                if ($characterBuild.Attributes.$_ -gt $raceTable[$i].BaseAttributes.$_)
                {
                    Write-Output "Spent points to raise attribute."
                }
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

calculateBuildCost $characterBuild $professionTiers $buildPointCosts