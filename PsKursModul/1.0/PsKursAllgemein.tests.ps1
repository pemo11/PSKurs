<#
 .Synopsis
 Tests für die Functions in PSKursAllgemein.psm1
#>

# Nicht erforderlich, nur der Form halber
Import-Module -Name Pester   

Import-Module -Name (Join-Path $PSScriptRoot -ChildPath PsKursAllgemein.psm1)

describe "Rundungstests" {
    it "Runden auf 3 Nachkommastellen" {
        $Result = Runden ([Math]::PI) 3
        $Result -eq 3.142 | should be $true
    } 
    it "Runden mit Default-Nachkommastellen" {
        $Result = Runden ([Math]::PI)
        $Result -eq 3.14 | should be $true
    } 
}