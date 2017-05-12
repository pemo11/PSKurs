<#
 .Synopsis
 Tests for the PsKurs-Module
#>

describe "General Tests" {

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
        (Info-LocalProgramfile).Count -gt 0 | Should be $true
    }

    it "should return more than 1 Uninstall-Entry" {
        (Info-UnInstallProg).Count -gt 0 | Should be $true
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

}