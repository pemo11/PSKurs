<#
 .Synopsis
 Ein paar allgemeine Functions
 .Notes
 APIKey = d1aa07e8-d006-410a-b040-acf131460a2f
 publish-module -Name PsKurs -Repository PoshRepo -NuGetApiKey d1aa07e8-d006-410a-b040-acf131460a2f
#>

<#
 .Synopsis
 Runden einer Zahl
#>
function Runden
{
    param([Double]$Zahl, [Int]$Anzahl=2)
    return [Math]::Round($Zahl, $Anzahl)
}

<#
 .Synopsis
 Feststellen, ob PowerShell als Administrator gestartet wurde
#>
function IsAdmin    
{
    [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value -contains "S-1-5-32-544"
}

<#
 .Synopsis
 Spracheausgabe
 .Notes
 Microsoft Hedda Desktop/de-DE oder Microsoft Zira Desktop/en-US
#>
function Out-Voice
{
    param([String]$Ausgabe, [String]$VoiceName)
    Add-Type -AssemblyName System.Speech
    $Speech = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    if ($VoiceName)
    {
        $Speech.SelectVoice($VoiceName)
    }
    $Speech.SpeakAsync($Ausgabe)
}

<#
 .Synopsis
 Gibt die Exe-Dateien der Programme-Verzeichnisse zur?ck
#>
function Get-LocalProgramfile
{
  [CmdletBinding()]
  param()
  $ProgPath = $env:ProgramFiles
  if (Test-Path -Path ${env:ProgramFiles(x86)})
  {
    $ProgPath = $env:ProgramFiles, ${env:ProgramFiles(x86)}
  }
  Get-ChildItem $ProgPath -Directory | Select-Object -Property Name, @{n="ExeFiles";e={ (Get-ChildItem $_.FullName -Filter *.exe -Recurse -Depth 1).Name -join ","}} | Where-Object ExeFiles
}

Set-Alias -Name iprogfi -Value Info-ProgrammFile

<#
 .Synopsis
 Gibt die Eckdaten der Uninstall-Eintraege zurueck
#>
function Get-UninstallProg
{
   [CmdletBinding()]
   param()
   $HKLMUninstall64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKCUUinstall64 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKLMUninstall32 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKCUUinstall32 = "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
   $HKLMUninstall64, $HKCUUinstall64, $HKLMUninstall32, $HKCUUinstall32 | ForEach-Object {
   if (Test-Path $_) 
   {
     Get-ItemProperty -Path $_\* | Select-Object -Property DisplayName, InstallLocation | Where-Object InstallLocation | Sort-Object Displayname
   } 
  }
}

Set-Alias -Name unappkey -Value Info-UninstallProg

<#
 .Synopsis
 Gibt die installierten .NET-Versionen aus
#>
function Get-NetVersion
{
  [CmdletBinding()]
  param([Parameter(ParametersetName="Version", Mandatory=$true, Position=0)][String]$Version,
        [Parameter(ParametersetName="ShowAll")][Switch]$ShowAll
        )
  if ($PSBoundParameters.ContainsKey("ShowAll") -or $PSBoundParameters.Count -eq 0)
  {
    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs  | 
      Select-Object @{n="NetVersion";e={ [Regex]::Match($_.Name, ".+=v(\d\.\d+[.\d+]*)").Groups[1].Value } } | Where-Object NetVersion |
       Sort-Object -Unique -Property NetVersion
  }
  if ($PSBoundParameters.ContainsKey("Version"))
  {
    $Result = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs  | 
      Select-Object @{n="NetVersion";e={ [Regex]::Match($_.Name, ".+=v(\d\.\d+[.\d+]*)").Groups[1].Value } } | 
        Where-Object NetVersion -eq $Version
      # Die folgende Abfrage geht nicht !
    # $Result -ne $null
    @($Result).Count -gt 0
  }
}