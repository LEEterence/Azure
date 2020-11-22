<# 
~ Obtain Ip address for VMs, added code to find public IP on top of source.
 - Added Pscustomobject to better structure output

 Changes: 
  - modified code to allow for multiple VMs to be remoted to. Changed PSCusom object to be instatiated outside of the foreach loop. A hashtable converted to PScustomobject type becomes each value of the results array.
  - Changed how the public IP address is obtained by searching directly for the resource ID, for some reason the previous method returned the ip addresses for multiple resources even though the VMs specific unique resource ID is specified.
#>

$VMs = Get-AzVM
$Nics = Get-AzNetworkInterface | Where-Object VirtualMachine -ne $null
# Setting VM IDs
$ID = 1
$results = @()

foreach($Nic in $Nics)
{
    $VM = $VMs | Where-Object -Property Id -eq $Nic.VirtualMachine.Id

    $PubID = ($Nic.IpConfigurations | Select-Object -ExpandProperty PublicIpAddress).ID
    $Pub = Get-AzPublicIpAddress | Where-Object {$_.Id -eq $pubid -and $_.IpAddress -ne $null} | Select-Object -ExpandProperty IpAddress
    #$Pub = (Get-AzPublicIpAddress -ResourceName $PubID).IpAddress

    $Prv = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAddress
    
    $Alloc = $Nic.IpConfigurations | Select-Object -ExpandProperty PrivateIpAllocationMethod

    # Outputting into custom table using pscustomobject
    $results += [PSCustomObject]@{
        ID = $ID
        Name = $($Vm.name)
        Private = $Prv
        Public = $Pub
        ResourceGroup = $VM.ResourceGroupName
        PrivateAllocationType = $Alloc
    }

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


# Source: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal