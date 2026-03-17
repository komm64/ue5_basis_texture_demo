# deploy_xuastc8x8.ps1
# Copies encoded XUASTC LDR 8x8 KTX2 normal maps into the UE project's basis_textures directory.
# Run this after encode_normals_xuastc8x8.ps1.

$src = Join-Path $PSScriptRoot "xuastc_8x8_textures"
$dst = Join-Path $PSScriptRoot "basis_textures"

New-Item -ItemType Directory -Force -Path $dst | Out-Null

Write-Host "=== Copying XUASTC LDR 8x8 normal maps ==="
Write-Host "  From : $src"
Write-Host "  To   : $dst"
Write-Host ""

$files = Get-ChildItem $src -Filter "*_nor_*.ktx2"
if ($files.Count -eq 0) {
    Write-Host "No KTX2 files found in: $src"
    Write-Host "Run encode_normals_xuastc8x8.ps1 first."
    exit 1
}

foreach ($f in $files) {
    Copy-Item $f.FullName (Join-Path $dst $f.Name) -Force
    Write-Host ("  {0}: {1:N0} KB" -f $f.Name, ($f.Length / 1KB))
}

Write-Host ""
Write-Host "Done. ($($files.Count) files)"
