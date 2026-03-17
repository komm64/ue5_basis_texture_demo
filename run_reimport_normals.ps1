# run_reimport_normals.ps1
# Reimports XUASTC LDR 8x8 KTX2 normal maps into UE5 via Python scripting.
# Requires the project to have been built at least once.
#
# Edit $ue_version if using a different engine version.

$ue_version = "UE_5.7"
$cmd  = "C:\Program Files\Epic Games\$ue_version\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
$proj = Join-Path $PSScriptRoot "BasisDemo.uproject"
$py   = Join-Path $PSScriptRoot "reimport_normals_uastc.py"

if (-not (Test-Path $cmd)) {
    Write-Host "UnrealEditor-Cmd.exe not found at: $cmd"
    Write-Host "Set `$ue_version to match your installed engine version."
    exit 1
}

& $cmd $proj "-ExecutePythonScript=$py" -nullrhi -unattended
Write-Host "Exit: $LASTEXITCODE"
