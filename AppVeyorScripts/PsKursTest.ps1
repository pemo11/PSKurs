#---------------------------------# 
# Test-Skript                     # 
#---------------------------------# 
Write-Host "Stufe 3: Das Test-Skript startet" -ForegroundColor Yellow

Write-Host "Aktuelles Arbeitsverzeichnis: $pwd"

#---------------------------------# 
# Pester Tests ausfuehren         # 
#---------------------------------# 
$TestResultsFile = ".\TestsResults.xml"
$TestsPath = ".\$($env:ModuleName).tests.ps1"
$Results  = Invoke-Pester -Script $TestsPath -OutputFormat NUnitXml -OutputFile $TestResultsFile -PassThru

Write-Host "Test-Ergebnisse in AppVeyor-Portal laden"
$WC = New-Object -Typename System.Net.WebClient
$WC.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $TestResultsFile))

#---------------------------------# 
# Test-Ergebnisse bewerten        # 
#---------------------------------# 
if (($Results.FailedCount -gt 0) -or ($Results.PassedCount -eq 0))
{
    throw "$($Results.FailedCount) Tests wurden nicht bestanden - Skript wird beendet."
    exit -1
}

Write-Host "*** Alle Tests wurden bestanden! ***" -ForegroundColor Green

#-----------------------------------------------------# 
# PSScriptAnalyzer mit Psm1-Datei ausfuehren          # 
# 
# Wichtig: Der Aufruf an dieser Stelle dient nur      #
# der Veranschaulichung, da die Skriptanalyse bereits #
# im Rahmen der Tests durchgefuehrt wird               #
#-----------------------------------------------------# 

$ModulName = $env:ModuleName
$Psm1Pfad = "./PsKursModul/$($env:ModuleVersion)/$ModulName.psm1"

$Result = Invoke-ScriptAnalyzer -Path $Psm1Pfad | Group-Object Severity 

# Anzahl der Fehler, Warnungen und Hinweis zaehlen
$Result | Sort-Object Name | ForEach-Object {
    Write-Host "Anzahl $($_.Name): $($_.Count)" -Fore Magenta
}

# Traten Fehler auf?
$ErrorCount = ($Result | Where-Object Name -eq "Error").Count 
if ($ErrorCount -gt 0)
{
    Write-Host "Die Skriptanalyse ergab $ErrorCount Fehler - Skript wird beendet."
    exit -1
}
else
{
    $WarningCount = ($Result | Where-Object Name -eq "Warning").Count 
    Write-Host "Die Skriptanalyse ergab keine Fehler ($WarningCount Warnungen)" -Fore Cyan
}