 # Admin commands if elevated
#  HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles --> Get every network the node connected too
# get-NetTCPConnection
# netsh wlan show profiles

# Run Admin commands if we have local admin or elevated privs
function AdmniPrivsActive {
    write-host "Local admin mode running"

}
# Run low priv commands 
function AdmniPrivsDeactivated {

    $TargetSMBShares = net use
    $LocalSubnetNodes = Get-NetNeighbor -AddressFamily IPv4 | select -Property IPAddress,LinkLayerAddress,State
    $KnownNTLMNode = Get-WinEvent -LogName "Microsoft-Windows-NTLM/Operational" -MaxEvents 1000 | ForEach-Object { $lines = $_.Message -split "`n"; $machine = $lines | Where-Object { $_ -match "Target Machine" } | ForEach-Object { ($_ -split ":\s*",2)[1].Trim() }; if ($machine) { $machine } } | Sort-Object -Unique
    $DNSClientLogs = Get-DnsClientCache | select -Property Entry,Data
    $RoutingInfo = Get-NetRoute | select -Property DestinationPrefix,NextHop
    $InterfaceInfo = Get-NetIPConfiguration


    $report = @()
    $report += "=== TARGET SMB SHARES ==="
    $report += $TargetSMBShares  | Out-String
    $report += "=== LOCAL SUBNET NODES ==="
    $report += $LocalSubnetNodes | Out-String
    $report += "=== KNOWN NTLM NODES ==="
    $report += $KnownNTLMNode    | Out-String
    $report += "=== DNS CLIENT LOGS ==="
    $report += $DNSClientLogs    | Out-String
    $report += "=== ROUTING INFO ==="
    $report += $RoutingInfo      | Out-String
    $report += "=== INTERFACE INFO ==="
    $report += $InterfaceInfo    | Out-String
    $report | Out-File -FilePath recon.txt -Encoding UTF8


}

# Check current users privs
$CurrentUser = "$env:USERDOMAIN\$env:USERNAME"
$LocalAdminMembers = $LocalAdminMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name

if ($LocalAdminMembers -contains $CurrentUser) {
    $ISLocalAdmin = $true
}else {
    $ISLocalAdmin = $false
}

if ($ISLocalAdmin) {
    AdmniPrivsActive
} else {
    Write-Host "Running with low privs - generating limited report"
    AdmniPrivsDeactivated
}
