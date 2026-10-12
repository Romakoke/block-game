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
# Browser-only web filtering. No system DNS server, firewall or network settings are changed.
$sites = @(
  'vseigru.net', 'roblox.com', 'rbx.com', 'rbxcdn.com',
  'yandex.ru/games', 'yandex.kz/games', 'yandex.com/games', 'yandex.by/games',
  'games.yandex.ru', 'games.yandex.kz', 'playhop.com', 'playhop.ru',
  'poki.com', 'crazygames.com', 'friv.com', 'friv4school.com',
  'gamepix.com', '1001games.com', 'kizi.com', 'y8.com',
  'lagged.com', 'minigames.com', 'silvergames.com', 'kongregate.com',
  'addictinggames.com', 'armorgames.com', 'coolmathgames.com', 'gamedistribution.com',
  'newgrounds.com', 'itch.io', 'now.gg', 'gameflare.com',
  'gamesgames.com', 'girlsgogames.com', 'agame.com', 'games.lol',
  'onlinegames.io', 'iogames.space', '1v1.lol', 'krunker.io',
  'shellshock.io', 'slowroads.io', 'agar.io', 'slither.io',
  'paper-io.com', 'diep.io', 'tbg95.com', 'unblockedgames66ez.com',
  'unblockedgames76.net', 'geometrydash.io', 'blockblast.io', 'littlealchemy2.com',
  'minecraft.net', 'minecraftservices.com', 'mojang.com', 'steampowered.com',
  'steamcommunity.com', 'epicgames.com', 'fortnite.com', 'ru.sgames.org',
  'sgames.org', 'multoigri.ru', 'igroutka.ru', 'games.pikabu.ru',
  'igru.net', 'bouncybasketball.com', 'gamelayer.ru', 'aif.ru/onlinegames',
  'games.yandex.by', 'yandex.com.tr/games', 'igry.ru', 'onlineminiigry.ru',
  'igryman.ru', 'online-igry.net', 'igry-dlya-devochek.ru', 'igry-na-dvoih.ru',
  'igraem.pro', 'igrat.online'
) | Select-Object -Unique
$browsers = @(
 'HKLM:\SOFTWARE\Policies\Google\Chrome',
 'HKLM:\SOFTWARE\Policies\Microsoft\Edge',
 'HKLM:\SOFTWARE\Policies\YandexBrowser'
)
$stateDir = Join-Path $env:ProgramData 'SchoolWebFilter2026'
$stateFile = Join-Path $stateDir 'installed_changes.json'
New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
if (Test-Path -LiteralPath $stateFile) {
  Write-Host 'This filter version is already installed. Use the removal file first to reset it.'
  return
}
$script:changes = New-Object System.Collections.Generic.List[object]

function Save-Progress {
  # File is written BEFORE changing the registry: rollback skips absent/modified values.
  $json = ConvertTo-Json -InputObject @($script:changes.ToArray()) -Depth 5
  [System.IO.File]::WriteAllText($stateFile, $json, [System.Text.Encoding]::UTF8)
}
function Add-PolicyValue([string]$path, [string]$name, [string]$value) {
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -Path $path -Force | Out-Null
  }
  $item = Get-Item -LiteralPath $path
  $oldExists = @($item.GetValueNames()) -contains $name
  $oldValue = $null
  if ($oldExists) { $oldValue = [string]$item.GetValue($name) }
  if ($oldExists -and $oldValue -ceq $value) { return }
  # Avoid silently overwriting incompatible value types.
  if ($oldExists -and $item.GetValueKind($name).ToString() -ne 'String') {
    Write-Warning "Skipped value with another registry type: $path : $name"
    return
  }
  $script:changes.Add([pscustomobject]@{
    Path=$path; Name=$name; NewValue=$value;
    OldExists=$oldExists; OldValue=$oldValue
  })
  Save-Progress
  New-ItemProperty -LiteralPath $path -Name $name -Value $value -PropertyType String -Force | Out-Null
}
function Add-UrlRule([string]$base, [string]$url) {
  $path = Join-Path $base 'URLBlocklist'
  if (-not (Test-Path -LiteralPath $path)) { New-Item -Path $path -Force | Out-Null }
  $item = Get-Item -LiteralPath $path
  $numericNames = @($item.GetValueNames() | Where-Object { $_ -match '^\d+$' })
  foreach ($name in $numericNames) {
    if ([string]$item.GetValue($name) -ceq $url) { return }
  }
  if ($numericNames.Count -ge 1000) { Write-Warning "URLBlocklist full: $path"; return }
  $used = @{}
  foreach ($name in $numericNames) { $used[$name] = $true }
  $n = 8001
  while ($used.ContainsKey([string]$n)) { $n++ }
  Add-PolicyValue $path ([string]$n) $url
}

try {
  foreach ($base in $browsers) {
    Write-Host "Configuring $base ..."
    foreach ($site in $sites) { Add-UrlRule $base $site }
    # Cloudflare Families adult + malware filtering, applied to each browser via DoH.
    # Does NOT change the Windows DNS settings or a school router's DNS.
    Add-PolicyValue $base 'DnsOverHttpsTemplates' 'https://family.cloudflare-dns.com/dns-query'
    Add-PolicyValue $base 'DnsOverHttpsMode' 'secure'
  }
  # Category filter is available only in the extended corporate edition of Yandex Browser.
  $cat = 'HKLM:\SOFTWARE\Policies\YandexBrowser\YandexContentFiltering'
  # Add individually so any already existing 'games' rule remains untouched.
  if (-not (Test-Path -LiteralPath $cat)) { New-Item -Path $cat -Force | Out-Null }
  $item = Get-Item -LiteralPath $cat
  foreach ($category in @('games','porn')) {
    if (@($item.GetValueNames() | Where-Object { $_ -match '^\d+$' -and ([string]$item.GetValue($_)) -eq $category }).Count -gt 0) { continue }
    $n = 8001
    while (@($item.GetValueNames()) -contains [string]$n) { $n++ }
    Add-PolicyValue $cat ([string]$n) $category
    $item = Get-Item -LiteralPath $cat
  }
  Write-Host "OK: $($sites.Count) site URL filters in each of 3 browsers; adult content DNS filtering configured."
  Write-Host 'Restart browsers and check chrome://policy, browser://policy and edge://policy.'
  Write-Host 'IMPORTANT: Student Windows accounts must be Standard (non-admin).'
  Write-Host 'If school-only internal sites stop working, run the removal file.'
}
catch {
  Write-Error "Failed: $_ . Use the removal script to restore settings."
  exit 1
}
