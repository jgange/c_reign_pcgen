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
    [int] $bps = 0
    $skillList = ($characterBuild.Skills | Get-Member -MemberType NoteProperty).Name
    $skillCost = $buildPointCosts.Skill

    $skillList | ForEach-Object { $bps+= $skillCost}
    return [int]$bps
}

function computeAttributesCost($characterBuild, $raceTable, $attributeTable)
{
    [int]$buildCost = 0
    for($i=0;$i -lt $raceTable.Count; $i++)
    {
        if ($raceTable.RaceName[$i] -eq [string]$characterBuild.Race)
        {
            $attributeCosts = $attributeTable.AttributeBase.[string]$raceTable[$i].AttributeBase
            $attributeList = ($raceTable[$i].BaseAttributes | Get-Member -MemberType NoteProperty).Name
            $attributeList | ForEach-Object {         
                if ($characterBuild.Attributes.$_ -gt $raceTable[$i].BaseAttributes.$_)
                {
                    #Write-Output "Raised attribute from $($raceTable[$i].BaseAttributes.$_) to $($characterBuild.Attributes.$_)"
                    $attributeValue = $characterBuild.Attributes.$_
                    $attributeCosts | ForEach-Object {
                        if ($_.Tier -eq $attributeValue) { $buildCost += [int]$_.buildPointCost}
                    }
                }
            }
        }
    }
    return $buildCost
}

function computeTraitsCost($characterBuild, $traitTable, $buildPointCosts)
{
    # Compute cost of the selected traits
    [int] $bps = 0

    $characterBuild.Traits | ForEach-Object {
        $characterTrait = $_
        $traitTable | ForEach-Object {
            if ($characterTrait -eq $_.TraitName)
            { 
                for($i=0; $i -lt $buildPointCosts.Traits.Count; $i++)
                {    
                    $trait = ($buildPointCosts.Traits[$i] | Get-Member -MemberType NoteProperty).Name
                    if ($trait-eq $_.TraitType)
                    {
                        $bps += [int]$buildPointCosts.Traits[$i].$Trait
                    }
                }
            }
        }
    }

    return $bps
}

function computeRareItemsCost($characterBuild, $buildPointCosts)
{
    [int] $bps = 0
    $characterBuild.RareItems | ForEach-Object { $bps += $buildPointCosts.RareItem }
    return $bps
}


function calculateBuildCost($characterBuild, $professionTiers, $buildPointCosts, $attributeTable)
{
    # Extract items that have a build cost
    [int] $totalBuildCost = 0

    $buildCosts = [PSCustomObject]@{
        Backgrounds  = computeBackgroundCost $characterBuild $professionTiers
        Skills       = computeSkillsCost     $characterBuild $buildPointCosts
        Attributes   = computeAttributesCost $characterBuild $raceTable        $attributeTable
        Traits       = computeTraitsCost     $characterBuild $traitTable       $buildPointCosts
        RareItems    = computeRareItemsCost  $characterBuild $buildPointCosts
    }

    ($buildCosts | Get-Member -MemberType NoteProperty).Name | ForEach-Object { 
        $totalBuildCost += $buildCosts.$_
    }

    return $totalBuildCost
}

#### MAIN PROGRAM ####

$raceTable       = populateData ($dataStoreLocation, $raceFile -join "\") 
$characterBuild = populateData ($dataStoreLocation, $buildsFile -join "\") 
$traitTable      = populateData ($dataStoreLocation, $traitsFile -join "\")
$systemRules     = populateData ($dataStoreLocation, $systemRulesFile -join "\")
$buildPointCosts = populateData ($dataStoreLocation, $buildCostsFile -join "\")
$attributeTable  = populateData ($dataStoreLocation, $attributeTableFile -join "\")
$professionTiers = populateData ($dataStoreLocation, $professionTiersFile -join "\")
$characterBuild  = populateData ($dataStoreLocation, $characterBuildFile -join "\")

$buildInfo = returnRecordSet $characterBuild "BuildType" $buildType
$raceInfo  = returnRecordSet $raceTable "RaceName" $characterBuild.Race

#$traitTable
#$systemRules
#$buildPointCosts
#$attributeTable
#$characterBuild
#$professionTiers

$characterBuild.BuildType
$raceInfo.RaceName

[int]$buildPointCost = calculateBuildCost $characterBuild $professionTiers $buildPointCosts $attributeTable
write-output "$($characterBuild.CharacterName) is a $buildPointCost build point character."