#---------------------------------# 
# Install-Skript                  # 
#---------------------------------#
Write-Host "Stufe 1: Das Install-Skript startet" -ForegroundColor Yellow

#---------------------------------# 
# NugetPackageProvider installieren
#---------------------------------# 
Write-Host "Der NuGet PackageProvider wird installiert"
$Package = Install-PackageProvider -Name NuGet -Force
Write-Host "Der NuGet PackageProvider wurd installiert $($Package.Version)"

#---------------------------------# 
# Pester installieren             # 
#---------------------------------# 
Write-Host "Das Pester-Modul wird aus der PSGallery installiert"
Install-Module -Name Pester -Repository PSGallery -Force

#---------------------------------# 
# PSScriptAnalyzer installieren   # 
#---------------------------------# 
Write-Host "PSScriptAnalyzer wird aus der PSGallery installiert"
Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force
