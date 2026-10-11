# Gem Gallery - one-step setup and launch (Windows).
#   powershell -ExecutionPolicy Bypass -File setup.ps1          set up (first time) and play
#   powershell -ExecutionPolicy Bypass -File setup.ps1 -Rebake  rebuild the halls after editing content
# Needs Godot 4.7: on PATH as "godot", or set $env:GODOT to the executable.
param([switch]$Rebake)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$godot = $env:GODOT
if (-not $godot) {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { $godot = $cmd.Source }
}
if (-not $godot) {
    Write-Host "Godot 4.7 was not found. Install it (for example: winget install GodotEngine.GodotEngine)" -ForegroundColor Yellow
    Write-Host "or download it from https://godotengine.org/download, then set `$env:GODOT to the .exe and run this again."
    exit 1
}
$ver = (& $godot --version) | Select-Object -First 1
Write-Host "Using Godot $ver"
if ($ver -notmatch '^4\.7') { Write-Host "Warning: this project is made for Godot 4.7." -ForegroundColor Yellow }

if (-not (Test-Path ".godot")) {
    Write-Host "Importing the project (first run only)..."
    & $godot --headless --path . --import | Out-Null
}
if ($Rebake -or -not (Test-Path "baked/manifest.res")) {
    Write-Host "Baking the halls (about a minute; a window opens and closes by itself)..."
    Start-Process $godot -ArgumentList '--path', '.', 'res://bake/bake.tscn' -Wait -NoNewWindow
    if (-not (Test-Path "baked/manifest.res")) { throw "Bake failed - see the output above." }
}
Write-Host "Starting the gallery. First launch can take a minute while shaders compile."
Start-Process $godot -ArgumentList '--path', '.'
