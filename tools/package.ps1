# Builds dist/GemGallery.zip: a folder a friend can unzip and double-click.
#   GemGallery.exe  = the Godot 4.7 runtime (it runs the .pck with the same name next to it)
#   GemGallery.pck  = the gallery (baked halls + scripts)
#   README.txt      = how to start, controls
# Run from the project folder:  powershell -File tools/package.ps1
# Re-bake first (res://bake/bake.tscn) if content changed.

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot)
$godot = (Get-Item (Get-Command godot).Source)
$engine = if ($godot.Target) { [string]$godot.Target } else { $godot.FullName }
New-Item -ItemType Directory -Force dist/GemGallery | Out-Null
$p = Start-Process godot -ArgumentList '--headless', '--path', '.', '--export-pack', '"Windows Desktop"', 'dist/GemGallery/GemGallery.pck' -NoNewWindow -Wait -PassThru
if (-not (Test-Path dist/GemGallery/GemGallery.pck)) { throw "Export failed" }
Copy-Item $engine dist/GemGallery/GemGallery.exe -Force
Copy-Item tools/friend_README.txt dist/GemGallery/README.txt -Force
if (Test-Path dist/GemGallery.zip) { Remove-Item dist/GemGallery.zip }
Compress-Archive -Path dist/GemGallery -DestinationPath dist/GemGallery.zip -CompressionLevel Optimal
Get-Item dist/GemGallery.zip | Select-Object FullName, @{n = 'MB'; e = { [math]::Round($_.Length / 1MB, 1) } }
