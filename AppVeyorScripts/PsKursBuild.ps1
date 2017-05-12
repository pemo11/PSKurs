#---------------------------------# 
# Build-Skript                    # 
#---------------------------------# 

Write-Host "Stufe 2: Das Build-Skript startet" -ForegroundColor Yellow

Write-Host "ModuleName    : $env:ModuleName"
Write-Host "Build version : $env:APPVEYOR_BUILD_VERSION"
Write-Host "Autor         : $env:APPVEYOR_REPO_COMMIT_AUTHOR"
Write-Host "Zweig         : $env:APPVEYOR_REPO_BRANCH"

Write-Host "`nHier gibt es nichts zu tun - auf zur naechsten Stufe..."