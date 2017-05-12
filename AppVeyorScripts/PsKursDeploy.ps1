#---------------------------------# 
# Deploy-Skript                   # 
#---------------------------------# 

Write-Host "Stufe 4: Das Deploy-Skript startet" -ForegroundColor Yellow
Write-Host "Aktuelles Arbeitsverzeichnis: $Pwd"

#---------------------------------# 
# Anlegen des Moduls              # 
#---------------------------------# 

Write-Host "Ein neues Modulmanifest wird angelegt"

$ModuleParentPath = Split-Path -Path $Pwd

Write-Host "$ModuleParentPath wird an die PSModulePath-Variablen angehaengt"
$env:PSModulePath += ";$ModuleParentPath"

$ModulePath = Join-Path -Path $Pwd -ChildPath $env:ModuleVersion
$Psm1Name = $env:ModuleName + ".psm1"
$Psd1Name = $env:ModuleName + ".psd1"
$Psm1Path = Join-Path -Path $ModulePath -ChildPath $Psm1Name

# Psd1-Datei wird neu angelegt
$ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $Psd1Name

# $env:APPVEYOR_BUILD_VERSION sollte für die Modulversion nicht verwendet werden

New-ModuleManifest -Path $ModuleManifestPath -Author "P. Monadjemi" `
 -Description "Functions und Beispiele für meine PowerShell-Schulungen" `
 -Copyright "Free as in free beer" `
 -Guid "36969b0a-09fc-4f5f-a879-025d455416b8" `
 -ModuleVersion 1.0 `
 -NestedModules $Psm1Name

# Optional: Festlegen der zu exportierenden Functions

# Warnung: So kompliziert muss man es nicht machen (auf der anderen Seite ist es nicht wirklich kompliziert, sondern eigentlich ganz naheliegend;)
$FuncListe = [Scriptblock]::Create((Get-Content $Psm1Path -Raw )).Ast.FindAll({param($Ast) $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Name -join ","

# Psd1-Datei aktualisieren
Update-ModuleManifest -Path $ModuleManifestPath -FunctionsToExport $FuncListe 

Write-Host "$ModuleManifestPath wurde aktualisiert..."

# Replace Version number in Manifest
# $ModuleManifest     = Get-Content -Path $ModuleManifestPath -Raw
# [regex]::replace($ModuleManifest,'(ModuleVersion = )(.*)',"`$1'$env:APPVEYOR_BUILD_VERSION'") | Out-File -LiteralPath $ModuleManifestPath

#---------------------------------# 
# Registering a PowerShell Repo   # 
#---------------------------------# 
function Register-PSRepositoryFix
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [Parameter(Mandatory=$true)]
        [Uri]
        $SourceLocation,
        [ValidateSet("Trusted", "Untrusted")]
        $InstallationPolicy = "Trusted"
    )

    $ErrorActionPreference = "Stop"

    try
    {
        Write-Verbose "Versuche das Repository $Name per Register-PSRepository zu registieren."
        Register-PSRepository -Name $Name -SourceLocation $SourceLocation -InstallationPolicy $InstallationPolicy
        Write-Verbose "Das Repository wurde tatsaechlich per Register-PSRepository registriert."
    }
    catch
    {
        Write-Verbose "Register-PSRepository ging leider nicht, verwende den Workaround"
        
        # Trage die Daten des Repositories direkt in PSRepositories.xml ein
        Register-PSRepository -Name $Name -SourceLocation $env:TEMP -InstallationPolicy $InstallationPolicy
        $PSRepositoriesXmlPath = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\PowerShellGet\PSRepositories.xml"
        $Repos = Import-Clixml -Path $PSRepositoriesXmlPath
        $PackageUri = (New-Object -TypeName Uri -ArgumentList $SourceLocation, "package/").AbsoluteUri
        $Repos[$Name].SourceLocation = $SourceLocation.AbsoluteUri
        $Repos[$Name].PublishLocation = $PackageUri
        $Repos[$Name].ScriptSourceLocation = $SourceLocation.AbsoluteUri
        $Repos[$Name].ScriptPublishLocation = $PackageUri
        $Repos | Export-Clixml -Path $PSRepositoriesXmlPath
        # PSGallery erneut initialisieren ???
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Write-Verbose "Repository $Name wurde per Workaround registriert"
    }
}

#----------------------------------------------# 
# Master-Branche in PoshRepo veroeffentlichen  # 
#----------------------------------------------# 
if ($env:APPVEYOR_REPO_BRANCH -notmatch "master")
{
    Write-Host "Es wird nur der Master-Branch veroeffentlicht - nicht $env:APPVEYOR_REPO_BRANCH - Skript wird beendet."
    exit -1
}

Write-Host "$env:ModuleName wird nach MyGet veroeffentlicht."

# PoshRepo wird registriert
$RepoUrlSource = "https://www.myget.org/F/poshrepo/api/v2/package2"
Register-PSRepositoryFix -Name PoshRepo -SourceLocation $RepoUrlSource -InstallationPolicy Trusted 

$ApiKey = "d1aa07e8-d006-410a-b040-acf131460a2f"

# Jetzt das Modul veroeffentlichen
Publish-Module -Name $env:ModuleName -NuGetApiKey $ApiKey -Repository PoshRepo