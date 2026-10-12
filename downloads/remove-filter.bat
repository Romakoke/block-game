@echo off
setlocal
fltmc >nul 2>&1
if errorlevel 1 (
  echo Administrator rights required. Right-click ^> Run as administrator.
  pause
  exit /b 1
)
set "SCRIPT_PATH=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$f=[System.IO.File]::ReadAllText($env:SCRIPT_PATH); $tag='::POWERSHELL_BELOW'; $p=$f.LastIndexOf($tag); if($p -lt 0){throw 'Missing script block'}; $code=$f.Substring($p+$tag.Length); & ([scriptblock]::Create($code))"
if errorlevel 1 echo Error! Please see messages above.
pause
exit /b
::POWERSHELL_BELOW
$ErrorActionPreference = 'Stop'
$stateFile = Join-Path (Join-Path $env:ProgramData 'SchoolWebFilter2026') 'installed_changes.json'
if (-not (Test-Path -LiteralPath $stateFile)) {
  Write-Host 'Nothing to remove: no saved changes from this version.'
  return
}
$entries = @(Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json)
$restored = 0
$skipped = 0
# Reverse order ensures DNS mode is restored before custom DNS template.
[array]::Reverse($entries)
foreach ($entry in $entries) {
  if (-not (Test-Path -LiteralPath $entry.Path)) { $skipped++; continue }
  $item = Get-Item -LiteralPath $entry.Path
  if (@($item.GetValueNames()) -notcontains [string]$entry.Name) { $skipped++; continue }
  $current = [string]$item.GetValue([string]$entry.Name)
  if ($current -cne [string]$entry.NewValue) { $skipped++; continue }
  try {
    if ($entry.OldExists -eq $true) {
      New-ItemProperty -LiteralPath $entry.Path -Name ([string]$entry.Name) -PropertyType String -Value ([string]$entry.OldValue) -Force | Out-Null
    } else {
      Remove-ItemProperty -LiteralPath $entry.Path -Name ([string]$entry.Name) -ErrorAction Stop
    }
    $restored++
  } catch {
    Write-Warning "Could not restore $($entry.Path) - $($entry.Name): $_"
    $skipped++
  }
}
if ($skipped -eq 0) {
  Remove-Item -LiteralPath $stateFile -Force
} else {
  Write-Warning 'Some values were not restored (possibly changed by another admin). State file retained for review.'
}
Write-Host "Restored/removed $restored values; skipped $skipped."
Write-Host 'Rules from earlier installers and unrelated policies were not removed.'
Write-Host 'Restart the three browsers.'
