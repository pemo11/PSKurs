<#
 .Synopsis
 Tests for the PsKurs-Module
#>

describe "Allgemeine Tests" {

    beforeAll {
        cd $PSScriptRoot
        $ModulName = $env:ModuleName
        $Psm1Pfad = "./$($env:ModuleVersion)/$ModulName.psm1"
        # Laden der Psm1-Datei mit den zu testenden Functions
        Import-Module $Psm1Pfad -PassThru -Force -DisableNameChecking
    }

    afterAll {
        Remove-Module -Name PsKurs
    }

    it "should return more than 1 Program File-Entry" {
        (Get-LocalProgramfile).Count -gt 0 | Should be $true
    }

    it "should return more than 1 Uninstall-Entry" {
        (Get-UnInstallProg).Count -gt 0 | Should be $true
    }

    it "ScriptAnalyzer should give no errors" {
        Import-Module PSScriptAnalyzer
        $RuleVioalations = Invoke-ScriptAnalyzer -Path $Psm1Pfad -ExcludeRule "PSUseApprovedVerbs"
        @($RuleVioalations | Where-Object Severity -eq "Error").Count | Should be 0
    }

    it "ScriptAnalyzer should give less than 3 warnings" {
        Import-Module PSScriptAnalyzer
        $RuleVioalations = Invoke-ScriptAnalyzer -Path $Psm1Pfad -ExcludeRule "PSUseApprovedVerbs"
        @($RuleVioalations | Where-Object Severity -eq "Warning").Count -lt 3 | Should be $true
    }

    it "Runden auf 3 Nachkommastellen" {
        $Result = Runden ([Math]::PI) 3
        $Result -eq 3.142 | should be $true
    }

    it "Runden mit Default-Nachkommastellen" {
        $Result = Runden ([Math]::PI)
        $Result -eq 3.14 | should be $true
    } 

}

describe "Chart-Modul Tests" {

    beforeAll {
        cd $PSScriptRoot
        $Ps1Pfad = "./$($env:ModuleVersion)/Scripts/OutChart.ps1"
        # Laden der Ps1-Datei mit drn zu testenden Function Out-Chart
        .$Ps1Pfad
    }

    it "Erzeugt Png-Datei" {
        $PngPfad = Join-Path -Path $env:temp -ChildPath "Chart1.png"
        $Daten = Get-Service | Group-Object -Property Status
        Out-Chart -FilePath $PngPfad `
          -ChartTitle "Test" `
          -XAxisTitle "X-Achse" `
          -YAxisTitle "Y-Achse" `
          -DataSource $Daten `
          -XAxisProperty "Name" `
          -Property1ScaleFactor 1 `
          -Property1 "Count"
        Test-Path -Path $PngPfad | Should be $true
    } 

}