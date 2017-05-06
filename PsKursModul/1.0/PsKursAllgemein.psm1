<#
 .Synopsis
 Allgemeine Functions
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