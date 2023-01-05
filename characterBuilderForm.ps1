Add-Type -AssemblyName PresentationFramework

$buildTypes = @{
    "Normal"    ="120"
    "Heroic"    ="240"
    "Ascendant" ="360"
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

$outputFile = $PSScriptRoot

$displayFormFilePath = $PSScriptRoot, "characterBuildForm.xaml" -join "\"

[xml]$xaml = Get-Content $displayFormFilePath

$Reader = (New-Object System.Xml.XmlNodeReader $xaml)
$characterBuildFormWindow = [Windows.Markup.XamlReader]::Load($Reader)

$playerName = $characterBuildFormWindow.FindName("playerNameValue")
$characterName = $characterBuildFormWindow.FindName("characterNameValue")
$characterBuild = $characterBuildFormWindow.FindName("buildSelector")
$characterBuildPoints = $characterBuildFormWindow.FindName("buildPoints")
$mainMenu =$characterBuildFormWindow.FindName("mainMenu")
$mainMenuFileExit = $characterBuildFormWindow.FindName("menuExitProgram")
$mainMenuFileSave = $characterBuildFormWindow.FindName("menuSaveFile")

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

$characterBuildFormWindow.ShowDialog()