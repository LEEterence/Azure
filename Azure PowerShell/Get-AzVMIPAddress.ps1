$VMs = Get-AzVM
$Nics = Get-AzNetworkInterface | Where VirtualMachine -ne $null

foreach($Nic in $Nics)
{
$VM = $VMs | Where-Object -Property Id -eq $Nic.VirtualMachine.Id
$Prv = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAddress
$Alloc = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAllocationMethod
Write-Output "$($VM.Name): $Prv,$Alloc"
}

# Source: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal