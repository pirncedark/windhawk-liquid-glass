# Shows whether the Windhawk mods are actually loaded into Explorer / Start menu.
foreach ($n in 'explorer','StartMenuExperienceHost') {
    $p = Get-Process $n -ErrorAction SilentlyContinue | Select-Object -First 1
    $mods = $p.Modules | Where-Object ModuleName -match 'styler' | ForEach-Object ModuleName
    "{0,-26} {1}" -f $n, $(if ($mods) { $mods -join ', ' } else { 'NO MODS LOADED' })
}
$svc = Get-CimInstance Win32_Service -Filter "Name='Windhawk'"
"Windhawk service: $($svc.State), start mode $($svc.StartMode)"
