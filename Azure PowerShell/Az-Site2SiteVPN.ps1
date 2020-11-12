<# 
Running RRAS on a server core
#>

import-module remoteaccess
install-remoteaccess -vpntype vpns2s

Add-VpnS2SInterface -Name "AzureVPN" 40.83.146.77 -Protocol IKEv2 –AuthenticationMethod PSKOnly –SharedSecret “<alphanumeric shared key>” -IPv4Subnet 10.0.0.0/16:10

Connect-VPNs2sInterface -Name AzureVPN

# NOTE: MUST DISABLE 'NetBios over TCPIP' within registry HKLM\System\Microsoft\CurrentControlSet\

# Change Virtual Network Gateway Pointing at
Set-VPNs2sinterface -name AzureVPN -IPaddress "<New Virtual Network Gateway Public IP>"
    # Optionally change PSK too or use the same one

# Optional (unless still unable to connect)
route -p ADD 10.0.0.0 MASK 255.255.0.0 "<VPN Server IP>" METRIC 10

# Change VPN Idle Disconnect Time
Set-VPNs2sinterface -name AzureVPN -IdleDisconnectSeconds <Number of Seconds>

<# Sources:
https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/jj574210(v=ws.11)
https://docs.microsoft.com/en-us/powershell/module/remoteaccess/add-vpns2sinterface?view=win10-ps #>