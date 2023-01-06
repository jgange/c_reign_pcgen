Add-Type -AssemblyName PresentationFramework

$buildTypes = @{
    "Normal"    = 120
    "Heroic"    = 240
    "Ascendant" = 360
}

$buildAttribPts = @{
    "Strength"     = 0
    "Constitution" = 0
    "Dexterity"    = 0
    "Size"         = 0
    "Intellect"    = 0
    "Power"        = 0
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

######## FUNCTIONS #############

function changeAttributeValue($controlName, $propertyName)
{
    $race = $characterRace.SelectedItem.Content
    $characterBuild = $characterBuild.Text
    $totalBuildPoints = $buildTypes.$characterBuild
    $attrib = $controlName.SelectedItem.Content
    [int]$buildPointCost = $attribCosts.$race.$attrib
    $buildAttribPts.$propertyName = $buildPointCost
    $totalSpent = $buildAttribPts.Strength + $buildAttribPts.Constitution + $buildAttribPts.Dexterity + $buildAttribPts.Size + $buildAttribPts.Intellect + $buildAttribPts.Power
    if ($totalSpent -gt $totalBuildPoints)
    { 
        [System.Windows.MessageBox]::Show('Not enough build points.')
    }
    else
    {
        $characterBuildPoints.Text = $totalBuildPoints - $totalSpent
    }
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
        if ($characterName.Text -eq "") 
        {
            $fileName = "default.json"
        }
        else
        {
            $charName = ([string]$characterName.Text) -replace " ",""
            $fileName = $charName,"json" -join "."
        }

        $outputFile = $outputFile, $fileName -join "\"
        $playerName.Text | Out-File -FilePath $outputFile -Append
        $characterName.Text | Out-File -FilePath $outputFile -Append
        $characterBuild.Text | Out-File -FilePath $outputFile -Append
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

$characterBuildFormWindow.ShowDialog() | Out-Null