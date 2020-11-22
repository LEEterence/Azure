<# 
~ Obtain Ip address for VMs, added code to find public IP on top of source.
 - Added Pscustomobject to better structure output

 Changes: 
  - modified to ignore ip addresses pulled from aadds vnets
#>

$VMs = Get-AzVM
$Nics = Get-AzNetworkInterface | Where-Object VirtualMachine -ne $null
# Setting VM IDs
$ID = 1
$results = @()

foreach($Nic in $Nics)
{
    # Conditional statement now skips over IDs if they don't output information for a VM
    if($VM = $VMs | Where-Object -Property Id -eq $Nic.VirtualMachine.Id){
        $PubID = ($Nic.IpConfigurations | Select-Object -ExpandProperty PublicIpAddress).ID
        $Pub = Get-AzPublicIpAddress | Where-Object {$_.Id -eq $pubid -and $_.IpAddress -ne $null} | Select-Object -ExpandProperty IpAddress
    
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