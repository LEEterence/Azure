## Create Azure Bastion subnet. ##
$bastsubnet = @{
    Name = 'AzureBastionSubnet' 
    AddressPrefix = '10.0.100.0/24'
}
$bastsubnetConfig = New-AzVirtualNetworkSubnetConfig @bastsubnet

#$virtualNetwork = Get-AzVirtualNetwork -Name sg-vnet
#Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $bastsubnetConfig
#$virtualNetwork | Set-AzVirtualNetwork

$readVNet = et-AzVirtualNetwork -Name sg-vnet
$virtualNetwork = Get-AzVirtualNetwork | Where-Object {$_.Name -like "*$readVNet*"}

#Add Additional Subnet 
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name "AzureBastionSubnet" `
    -AddressPrefix "10.0.100.0/24" `
    -VirtualNetwork $virtualNetwork 

#Write the changes to the VNET (DOES NOT need $subnetconfig variable)
$virtualNetwork | Set-AzVirtualNetwork

## Create public IP address for bastion host. ##
$ip = @{
    Name = 'sg-BastionIP'
    ResourceGroupName = 'sleepygeeks'
    Location = 'westus2'
    Sku = 'Standard'
    AllocationMethod = 'Static'
}
$publicip = New-AzPublicIpAddress @ip

## Create bastion host ##
$bastion = @{
    ResourceGroupName = 'sleepygeeks'
    Name = 'sg-bastionhost'
    PublicIpAddress = $publicip
    VirtualNetwork = $virtualNetwork
}
New-AzBastion @bastion -AsJob