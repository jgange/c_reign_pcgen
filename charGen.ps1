#### INITIALIZATION ####

$dataStoreLocation   = "C:\Users\jgange\Projects\PowerShell\c_reign_pcgen"
$raceFile            = "races.json"
$buildsFile          = "builds.json"
$traitsFile          = "traits.json"
$systemRulesFile     = "systemRules.json"
$buildCostsFile      = "buildPointCost.json"
$attributeTableFile  = "attributesTable.json"
$professionTiersFile = "professionTiers.json"
$boonsFile           = "boons.json"
$contactsFile        = "contacts.json"
$spellsFile          = "spells.json"
$characterBuildFile  = "brak.json"


#### METHODS ####

function populateData($filePath)
{
    return Get-Content -Path $filePath | ConvertFrom-Json
}

function returnRecordSet($records, $propertyName, $value)
{
    $records | Where-Object {$_.$propertyName -eq $value}
}

function returnProperties($object, $parentProperty)
{
    if ($parentProperty)
    {
        return ($object.$parentProperty | Get-Member -membertype noteproperty | ForEach-Object name)
    }
    else
    {
        return ($object | Get-Member -membertype noteproperty | ForEach-Object name)
    }
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

function computeSkillRaiseCost($characterBuild)
{
    [int] $bps = 0
    
    $increases = [System.Collections.ArrayList]@()
    $characterBuild.Skills | Get-Member -membertype noteproperty | ForEach-Object name | ForEach-Object { $increases.Add($characterBuild.Skills.$_) | Out-Null }
    $characterBuild.SkillIncreases | Get-Member -membertype noteproperty | ForEach-Object name | ForEach-Object { $increases.Add($characterBuild.SkillIncreases.$_) | Out-Null }
    
    for($i=0; $i -lt ($increases.Count/2); $i++)
    {
        $score = $increases[$i]
        for ($k = 0; $k -lt $increases[$i+2]; $k++)
        {
            $bps = $bps + [int][math]::Floor($score/10)
            $score++
        }
    }
    return $bps
}

function computeSpellCost($characterBuild, $spellsTable)
{
    # based on quintessence cost of spell - requires the spell list to be seeded
    [int] $bps = 0

    $characterBuild.Spells | ForEach-Object {
        $spell = $_
        returnProperties $spellsTable | ForEach-Object {
            if ($spell -eq $_)
            {
                $bps += ($spellsTable.$_."Cost in Quintessence Points" *2)
            }
        }
    }

    if ($characterBuild.Traits -match "Eldritch Heritage")
    {
        $bps =[int][math]::Floor($bps / 2)
    }

    return $bps
}

function computeRacialAbilities($characterBuild)
{
    # make sure races seed file includes tiered abilities with costs
    [int] $bps = 0
    return $bps
}

function computeContactsCost($characterBuild, $contactsTable)
{
    # needs a seed file also
    [int] $bps = 0

    $characterBuild.Contacts | ForEach-Object {
        $contact = $_
        returnProperties $contactsTable | ForEach-Object {
            if ($contact -eq $_)
            {
                $bps += $contactsTable.$_.Cost
            }
        }
    }

    return $bps
}

function computeBoonCost($characterBuild, $boonsTable)
{
    #  needs a seed file
    [int] $bps = 0

    $characterBuild.Boons | ForEach-Object {
        # Outerloop which compare each boon on the character sheet against the list to get the cost
        $boon = $_
        returnProperties $boonsTable | ForEach-Object {
            if ($boon -eq $_)
            {
                $bps += $boonsTable.$_.Cost
            }
        }
    }

    return $bps
}

function computeTaintCost($characterBuild)
{
    # this one is just a rule, no seed file required
    return -([int]$characterBuild.Taint * 5)
}
function calculateBuildCost($characterBuild, $professionTiers, $buildPointCosts, $attributeTable)
{
    # Extract items that have a build cost
    [int] $totalBuildCost = 0

    $Global:buildCosts = [PSCustomObject]@{
        Backgrounds     = computeBackgroundCost  $characterBuild $professionTiers
        Skills          = computeSkillsCost      $characterBuild $buildPointCosts
        Attributes      = computeAttributesCost  $characterBuild $raceTable        $attributeTable
        Traits          = computeTraitsCost      $characterBuild $traitTable       $buildPointCosts
        RareItems       = computeRareItemsCost   $characterBuild $buildPointCosts
        SkillRaises     = computeSkillRaiseCost  $characterBuild
        Spells          = computeSpellCost       $characterBuild $spellsTable
        Contacts        = computeContactsCost    $characterBuild $contactsTable
        RacialAbilities = computeRacialAbilities $characterBuild
        Boons           = computeBoonCost        $characterBuild $boonsTable
        Taint           = computeTaintCost       $characterBuild
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
$boonsTable      = populateData ($dataStoreLocation, $boonsFile -join "\")
$contactsTable   = populateData ($dataStoreLocation, $contactsFile -join "\")
$spellsTable     = populateData ($dataStoreLocation, $spellsFile -join "\")

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
$buildCosts
write-output "$($characterBuild.CharacterName) is a $buildPointCost build point character."