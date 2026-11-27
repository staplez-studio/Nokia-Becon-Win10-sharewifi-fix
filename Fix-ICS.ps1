# Fix-ICS.ps1
# Resets Internet Connection Sharing (Wi-Fi -> Ethernet) after boot.
# Steps: disable Ethernet, turn off sharing on Wi-Fi, enable Ethernet,
#        turn sharing back on (Wi-Fi shares to Ethernet).

$WifiName     = "Wi-Fi"      # adapter that has the internet (connected to "bearden")
$EthernetName = "Ethernet"   # adapter that receives the shared connection
$LogFile      = "C:\Scripts\Fix-ICS.log"

function Log($msg) {
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
    Add-Content -Path $LogFile -Value $line
}

function Get-SharingConfig($share, $name) {
    foreach ($conn in $share.EnumEveryConnection) {
        if ($share.NetConnectionProps.Invoke($conn).Name -eq $name) {
            return $share.INetSharingConfigurationForINetConnection.Invoke($conn)
        }
    }
    throw "Adapter '$name' not found"
}

try {
    Log "---- Starting ICS reset ----"

    # 1. Disable Ethernet
    Disable-NetAdapter -Name $EthernetName -Confirm:$false
    Log "Ethernet disabled"
    Start-Sleep -Seconds 3

    # 2. Uncheck sharing on Wi-Fi (and clear it on Ethernet too)
    $share = New-Object -ComObject HNetCfg.HNetShare
    $wifiCfg = Get-SharingConfig $share $WifiName
    $wifiCfg.DisableSharing()
    Log "Sharing turned off on Wi-Fi"

    # 3. Enable Ethernet
    Enable-NetAdapter -Name $EthernetName -Confirm:$false
    Log "Ethernet enabled"
    Start-Sleep -Seconds 5

    # 4. Re-check sharing: Wi-Fi = public (0), Ethernet = private (1)
    $share   = New-Object -ComObject HNetCfg.HNetShare
    $wifiCfg = Get-SharingConfig $share $WifiName
    $ethCfg  = Get-SharingConfig $share $EthernetName
    $ethCfg.DisableSharing()
    $wifiCfg.EnableSharing(0)
    $ethCfg.EnableSharing(1)
    Log "Sharing turned back on (Wi-Fi -> Ethernet)"

    Log "Done"
}
catch {
    Log "ERROR: $_"
    # Make sure Ethernet doesn't stay disabled if something failed
    Enable-NetAdapter -Name $EthernetName -Confirm:$false -ErrorAction SilentlyContinue
}
