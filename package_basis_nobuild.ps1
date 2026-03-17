# package_basis_nobuild.ps1
# Packages the Basis build (ETC1S albedo + XUASTC LDR 8x8 normals).
# Uses cook-only (no -build); assumes the project has already been compiled.
#
# Edit $ue_version and $archive to match your environment.

$ue_version = "UE_5.7"
$uat     = "C:\Program Files\Epic Games\$ue_version\Engine\Build\BatchFiles\RunUAT.bat"
$project = Join-Path $PSScriptRoot "BasisDemo.uproject"
$archive = Join-Path $PSScriptRoot "Packaged\Basis"
$ini     = Join-Path $PSScriptRoot "Config\DefaultEngine.ini"

$content = Get-Content $ini -Raw
$content = $content -replace "GameDefaultMap=/Game/Map_Standard", "GameDefaultMap=/Game/Map_Basis"
Set-Content $ini $content
Write-Host "Set GameDefaultMap = Map_Basis"

$start = Get-Date
Write-Host "=== Basis build (cook only) started: $start ==="

& $uat BuildCookRun `
    -project="$project" `
    -noP4 -platform=Win64 -clientconfig=Shipping `
    -cook -stage -pak -archive `
    -archivedirectory="$archive" `
    -map=Map_Basis `
    -unattended -nullrhi `
    -stagingdirectory="$(Join-Path $PSScriptRoot 'Saved\StagedBuilds\Basis')"

$elapsed = (Get-Date) - $start

$content = Get-Content $ini -Raw
$content = $content -replace "GameDefaultMap=/Game/Map_Basis", "GameDefaultMap=/Game/Map_Standard"
Set-Content $ini $content
Write-Host "Restored GameDefaultMap = Map_Standard"

Write-Host ""
Write-Host "=== Done: exit code $LASTEXITCODE ==="
Write-Host ("Cook+Package time: {0:mm}m {0:ss}s" -f $elapsed)

$pak = Join-Path $archive "Windows\BasisDemo\Content\Paks\BasisDemo-Windows.pak"
if (Test-Path $pak) {
    Write-Host ("Basis pak (XUASTC 8x8 normals): {0:N1} MB" -f ((Get-Item $pak).Length / 1MB))
}
