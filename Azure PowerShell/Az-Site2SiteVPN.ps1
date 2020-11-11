<# 
Running RRAS on a server core
#>

import-module remoteaccess
install-remoteaccess -vpntype vpns2s

Add-VpnS2SInterface -Name "AzureVPN" 40.83.146.77 -Protocol IKEv2 –AuthenticationMethod PSKOnly –SharedSecret “<alphanumeric shared key>” -IPv4Subnet 10.0.0.0/16:10

Connect-VPNs2sInterface -Name AzureVPN

# NOTE: MUST DISABLE 'NetBios over TCPIP' within registry HKLM\System\Microsoft\CurrentControlSet\

# Optional (unless still unable to connect)
route -p ADD 10.0.0.0 MASK 255.255.0.0 "<VPN Server IP>" METRIC 10

<# Sources:
https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/jj574210(v=ws.11)
https://docs.microsoft.com/en-us/powershell/module/remoteaccess/add-vpns2sinterface?view=win10-ps #>