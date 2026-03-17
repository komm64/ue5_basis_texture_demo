# package_standard_timed.ps1
# Packages the Standard build (BC1/BC5 + Oodle Texture RDO, lambda=30).
# Uses -build to compile before cooking; measures total time.
#
# Edit $ue_version and $archive to match your environment.

$ue_version = "UE_5.7"
$uat     = "C:\Program Files\Epic Games\$ue_version\Engine\Build\BatchFiles\RunUAT.bat"
$project = Join-Path $PSScriptRoot "BasisDemo.uproject"
$archive = Join-Path $PSScriptRoot "Packaged\Standard"

$start = Get-Date
Write-Host "=== Standard build (Oodle Texture RDO enabled) started: $start ==="

& $uat BuildCookRun `
    -project="$project" `
    -noP4 -platform=Win64 -clientconfig=Shipping `
    -build -cook -stage -pak -archive `
    -archivedirectory="$archive" `
    -map=Map_Standard `
    -unattended -nullrhi `
    -stagingdirectory="$(Join-Path $PSScriptRoot 'Saved\StagedBuilds\Standard')"

$elapsed = (Get-Date) - $start
Write-Host ""
Write-Host "=== Done: exit code $LASTEXITCODE ==="
Write-Host ("Cook+Package time: {0:mm}m {0:ss}s" -f $elapsed)

$pak = Join-Path $archive "Windows\BasisDemo\Content\Paks\BasisDemo-Windows.pak"
if (Test-Path $pak) {
    Write-Host ("Standard pak (OodleTexture RDO): {0:N1} MB" -f ((Get-Item $pak).Length / 1MB))
}
