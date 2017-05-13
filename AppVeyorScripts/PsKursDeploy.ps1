#---------------------------------# 
# Deploy-Skript                   # 
#---------------------------------# 

Write-Host "Stufe 4: Das Deploy-Skript startet" -ForegroundColor Yellow
Write-Host "Aktuelles Arbeitsverzeichnis: $Pwd"

$StartZeit = Get-Date

#---------------------------------# 
# Anlegen des Moduls              # 
#---------------------------------# 

Write-Host "Ein neues Modulmanifest wird angelegt"

$ModuleParentPath = Split-Path -Path $Pwd
$ModulePath = $Pwd

Write-Host "$ModulePath wird an die PSModulePath-Variablen angehaengt"
$env:PSModulePath += ";$ModulePath"

# Nur zu Testzwecken
Write-Host ((Get-ChildItem -Path $ModuleParentPath -Recurse).FullName -join ",")

# Versionsverzeichnis anhängen
$ModulePath = Join-Path -Path $ModulePath -ChildPath $env:ModuleVersion

# Pfade für die Psm1- und die Psd1-Datei bilden
$Psm1Name = $env:ModuleName + ".psm1"
$Psd1Name = $env:ModuleName + ".psd1"
$Psm1Path = Join-Path -Path $ModulePath -ChildPath $Psm1Name

# Psd1-Datei wird neu angelegt
$Psd1Path = Join-Path -Path $ModulePath -ChildPath $Psd1Name

# $env:APPVEYOR_BUILD_VERSION sollte fur die Modulversion nicht verwendet werden

New-ModuleManifest -Path $Psd1Path -Author "P. Monadjemi" `
 -Description "Functions und Beispiele fuer meine PowerShell-Schulungen" `
 -Copyright "Free as in free beer" `
 -Guid "36969b0a-09fc-4f5f-a879-025d455416b8" `
 -ModuleVersion 1.0 `
 -NestedModules $Psm1Name

Write-Host "Die Modulmanifestdatei $Psd1Path wurde neu erstellt."

# Optional: Festlegen der zu exportierenden Functions

# Warnung: So kompliziert muss man es nicht machen (auf der anderen Seite ist es nicht wirklich kompliziert, sondern eigentlich ganz naheliegend;)
$FuncListe = [Scriptblock]::Create((Get-Content $Psm1Path -Raw )).Ast.FindAll({param($Ast) $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Name -join ","

# Psd1-Datei aktualisieren
Update-ModuleManifest -Path $Psd1Path -FunctionsToExport $FuncListe 

Write-Host "Die Modulmanifestdatei $Psd1Path wurde aktualisiert..."

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

# Abschlussmeldung ausgeben
Write-Host ("Autrag ausgeführt in {0:n2}s" -f ((Get-Date)-$StartZeit).TotalSeconds)