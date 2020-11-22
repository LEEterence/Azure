<# 
~ Obtain Ip address for VMs, added code to find public IP on top of source.
 - Added Pscustomobject to better structure output

#>

$VMs = Get-AzVM
$Nics = Get-AzNetworkInterface | Where-Object VirtualMachine -ne $null
# Setting VM IDs
$ID = 0
foreach($Nic in $Nics)
{
    $VM = $VMs | Where-Object -Property Id -eq $Nic.VirtualMachine.Id

    $PubID = ($Nic.IpConfigurations | Select-Object -ExpandProperty PublicIpAddress).ID
    $Pub = (Get-AzPublicIpAddress -ResourceName $PubID).IpAddress

    $Prv = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAddress
    
    $Alloc = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAllocationMethod

    # Outputting into custom table using pscustomobject
    $results += [pscustomobject]@{ID = $ID;Name = $($Vm.name);Private = $Prv;Public = $Pub;ResourceGroup = $VM.ResourceGroupName;PrivateAllocationType = $Alloc}

    $ID++
}
# Output all VMs
$results | Format-Table -AutoSize

# Selecting VMs to RDP into
$Rdp = Read-Host "Select ID to RDP into"
foreach ($result in $results) {
    if ($result.ID -eq $Rdp){
        Write-Host "Remoting into $($result.Name)" -ForegroundColor Cyan
        mstsc.exe /v:$($result.public)
    }
}


#mstsc.exe /v:$pub
# Source: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal