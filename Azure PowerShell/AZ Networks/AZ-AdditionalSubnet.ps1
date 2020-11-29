 <# 
 ~ Used to add subnet to existing VNet - skip to #Add Additional Subnet 
 Source: skylines
 #>

 try{
    $readVNet = Read-Host "Enter Virtual Network"
    $virtualNetwork = Get-AzVirtualNetwork | Where-Object {$_.Name -like "*$readVNet*"}
   
    #Add Additional Subnet 
    $subnetConfig = Add-AzVirtualNetworkSubnetConfig `
       -Name "LastSubnet" `
       -AddressPrefix "10.0.4.0/24" `
       -VirtualNetwork $virtualNetwork 
   
    #Write the changes to the VNET (DOES NOT need $subnetconfig variable)
    $virtualNetwork | Set-AzVirtualNetwork
 }catch{
    Write-Host "$readVNet doesn't exist. Try again"
 }