Add-Type -AssemblyName PresentationFramework

# Probably need a single list of all the items which have costs associated along with a UI type and label name

$buildTypes = @{
    "Normal"    = 120
    "Heroic"    = 240
    "Ascendant" = 360
}

# Skills would have to be added or should everything added dynamically?
$buildAttribPts = [ordered]@{
    "Strength"         = 0
    "Constitution"     = 0
    "Dexterity"        = 0
    "Size"             = 0
    "Intellect"        = 0
    "Power"            = 0
    "ProfessionTier1"  = 0
    "ProfessionTier2"  = 0
}

$attribCosts = [ordered]@{
    "Human" = [ordered]@{
        "10"=-10
        "20"=0
        "30"=10
        "40"=20
        "50"=50
        "60"=90
    }
    "Draikosi" = [ordered]@{
        "10"=-10
        "20"=0
        "30"=10
        "40"=20
        "50"=50
        "60"=90
    }
}

$backgroundTierCosts = [ordered]@{
    "Novice"     =  30
    "Journeyman" =  60
    "Expert"     =  90
    "Master"     = 120
}

######## FUNCTIONS #############

function updateTotalBuildCost()
{
    $characterBuild = $characterBuild.Text
    $totalBuildPoints = $buildTypes.$characterBuild
    $totalSpent = $buildAttribPts.Strength + $buildAttribPts.Constitution + $buildAttribPts.Dexterity + $buildAttribPts.Size + $buildAttribPts.Intellect + $buildAttribPts.Power + $buildAttribPts.ProfessionTier1 + $buildAttribPts.ProfessionTier2 
    if ($totalSpent -gt $totalBuildPoints)
    { 
        [System.Windows.MessageBox]::Show('Not enough build points.')
    }
    else
    {
        $characterBuildPoints.Text = $totalBuildPoints - $totalSpent
    }
}

function changeAttributeValue($controlName, $propertyName)
{
    $race = $characterRace.SelectedItem.Content
    $attrib = $controlName.SelectedItem.Content
    [int]$buildPointCost = $attribCosts.$race.$attrib
    $buildAttribPts.$propertyName = $buildPointCost
    updateTotalBuildCost
}

function selectBackgroundTier($backgroundTierCosts, $tier, $property)
{
    [int]$cost = $backgroundTierCosts.$tier
    $buildAttribPts.$property = $cost
    updateTotalBuildCost
}

function collectPropertiesIntoRecord()
{
    # Grab all the properties from the window and output them into an object
    $characterBuild = [PSCustomObject]@{
        PlayerName         = $playerName.Text
        CharacterName      = $characterName.Text
        CharacterBuildType = $characterBuild.Text
        Strength           = $strengthValue.SelectedItem.Content
        Constitution       = $constitutionValue.SelectedItem.Content
        Dexterity          = $dexterityValue.SelectedItem.Content
        Size               = $sizeValue.SelectedItem.Content
        Intellect          = $intellectValue.SelectedItem.Content
        Power              = $powerValue.SelectedItem.Content
        Profession1Name    = $profession1Value.SelectedItem.Content
        Profession1Tier    = $tier1backgroundValue.SelectedItem.Content
        Profession2Name    = $profession2Value.SelectedItem.Content
        Profession2Tier    = $tier2backgroundValue.SelectedItem.Content
    }

    return $characterBuild
}

function generateFileName($targetFolder)
{
    if ($characterName.Text -eq "") 
        {
            $fileName = "default.json"
        }
        else
        {
            $charName = ([string]$characterName.Text) -replace " ",""
            $fileName = $charName,"json" -join "."
        }

    $outputFileName = $targetFolder, $fileName -join "\"

    return $outputFileName
}

function writeUpdatesToFile()
{
    # write the character record object out
    $characterRecord = collectPropertiesIntoRecord
    $fileName = generateFileName $outputFile
    $characterRecord | ConvertTo-Json | Out-File -FilePath $fileName
}

######## MAIN PROGRAM ##########

$outputFile = $PSScriptRoot
$displayFormFilePath = $PSScriptRoot, "characterBuildForm.xaml" -join "\"

[xml]$xaml = Get-Content $displayFormFilePath

$Reader = (New-Object System.Xml.XmlNodeReader $xaml)
$characterBuildFormWindow = [Windows.Markup.XamlReader]::Load($Reader)

$playerName           = $characterBuildFormWindow.FindName("playerNameValue")
$characterName        = $characterBuildFormWindow.FindName("characterNameValue")
$characterBuild       = $characterBuildFormWindow.FindName("buildSelector")
$characterBuildPoints = $characterBuildFormWindow.FindName("buildPoints")
$characterRace        = $characterBuildFormWindow.FindName("raceSelector")
$mainMenuFileExit     = $characterBuildFormWindow.FindName("menuExitProgram")
$mainMenuFileSave     = $characterBuildFormWindow.FindName("menuSaveFile")
$strengthValue        = $characterBuildFormWindow.FindName("strengthValue")
$constitutionValue    = $characterBuildFormWindow.FindName("constitutionValue")
$dexterityValue       = $characterBuildFormWindow.FindName("dexterityValue")
$sizeValue            = $characterBuildFormWindow.FindName("sizeValue")
$intellectValue       = $characterBuildFormWindow.FindName("intellectValue")
$powerValue           = $characterBuildFormWindow.FindName("powerValue")
$profession1Value     = $characterBuildFormWindow.FindName("background1Value")
$tier1backgroundValue = $characterBuildFormWindow.FindName("tier1backgroundValue")
$profession2Value     = $characterBuildFormWindow.FindName("background2Value")
$tier2backgroundValue = $characterBuildFormWindow.FindName("tier2backgroundValue")

$characterBuildPoints.Text = $buildTypes[$characterBuild.Text]

$characterBuild.Add_SelectionChanged(
    {
        switch($characterBuild.SelectedItem.Content)
        {
            "Normal"    {$characterBuildPoints.Text="120"}
            "Heroic"    {$characterBuildPoints.Text="240"}
            "Ascendant" {$characterBuildPoints.Text="360"}
        }
    }
)

$mainMenuFileExit.Add_Click(
    { $characterBuildFormWindow.Close() }
)

$mainMenuFileSave.Add_Click(
    {
        #Save the data
        writeUpdatesToFile
    }
)

$strengthValue.Add_SelectionChanged(
    {
        changeAttributeValue $strengthValue "Strength"
    }
)

$constitutionValue.Add_SelectionChanged(
    {
        changeAttributeValue $constitutionValue "Constitution"
    }
)

$dexterityValue.Add_SelectionChanged(
    {
        changeAttributeValue $dexterityValue "Dexterity"
    }
)

$sizeValue.Add_SelectionChanged(
    {
        changeAttributeValue $sizeValue "Size"
    }
)

$intellectValue.Add_SelectionChanged(
    {
        changeAttributeValue $intellectValue "Intellect"
    }
)

$powerValue.Add_SelectionChanged(
    {
        changeAttributeValue $powerValue "Power"
    }
)

$profession1Value.Add_SelectionChanged(
    {
        $prof = $profession1Value.SelectedItem.Content
        if ($prof -eq 'None')
        {
            # refund the points back
            $buildAttribPts.ProfessionTier1 = 0
            updateTotalBuildCost
        }
        else
        {
            selectBackgroundTier $backgroundTierCosts $tier1backgroundValue.SelectedItem.Content ProfessionTier1
        }
    }
)

$tier1backgroundValue.Add_SelectionChanged(
    {
        if ($profession1Value.SelectedItem.Content -ne 'None')
        {
            selectBackgroundTier $backgroundTierCosts $tier1backgroundValue.SelectedItem.Content ProfessionTier1
        }
    }
)

$profession2Value.Add_SelectionChanged(
    {
        $prof = $profession2Value.SelectedItem.Content

        if ($prof -eq 'None')
        {
            # refund the points back
            # [System.Windows.MessageBox]::Show('Reset to None.')
            $buildAttribPts.ProfessionTier2 = 0
            updateTotalBuildCost
        }
        else
        {
            selectBackgroundTier $backgroundTierCosts $tier2backgroundValue.SelectedItem.Content ProfessionTier2
        }
    }
)

$tier2backgroundValue.Add_SelectionChanged(
    {
        if ($profession2Value.SelectedItem.Content -ne 'None')
        {
            selectBackgroundTier $backgroundTierCosts $tier2backgroundValue.SelectedItem.Content ProfessionTier2
        }
    }
)

$characterBuildFormWindow.ShowDialog() | Out-Null