<# 
~ Creating VMSS through powershell
Source: https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/quick-create-powershell
https://www.youtube.com/watch?v=I-AitAKC-pA&t=233s

Configureing VMSS object cmdlets
New-AzVmssConfig
- Set-AzVmssOsProfile
- Set-AzVmssStorageProfile
- Add-AzVmssNetworkInterfaceConfiguration
- Add-AzVmssExtension
#>

$location = "WestUS"
$ResourceGroupName = "SoftwareJuice"
$vmssname = "sg-vmss"
$vnet = "sj-vnet"

##@ Create RG ##
if(-not($ResourceGroupName = New-AzResourceGroup -ResourceGroupName $ResourceGroupName -Location $location)){
    New-AzResourceGroup `
    -ResourceGroupName $ResourceGroupName `
    -Location $location
}else{
    Write-Verbose "Resource Group [$($resourcegroupname)] exists."
}

###@ Create config object ##
#$vmssConfig = New-AzVmssConfig `
#  -Location $location `
#  -SkuCapacity 2 `
#  -SkuName Standard_B1ms `
#  -UpgradePolicyMode Automatic

##@ Create VM Scale Set ##
New-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VMScaleSetName $vmssname `
  -VirtualNetworkName "$vnet" `
  -SubnetName "mySubnet" `
  -PublicIpAddressName "myPublicIPAddress" `
  -LoadBalancerName "myLoadBalancer" `
  -UpgradePolicyMode "Automatic"

##@ Define the script for your Custom Script Extension to run ##
$publicSettings = @{
    "fileUris" = (,"https://sgstorage123.blob.core.windows.net/vmss/automate-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}

#@ Allow traffic to application
## Get information about the scale set ##
$vmss = Get-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $vmssname

## Use Custom Script Extension to install IIS and configure basic website ##
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
    -Name "customScript" `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings

## Update the scale set and apply the Custom Script Extension to the VM instances ##
Update-AzVmss `
    -ResourceGroupName $ResourceGroupName `
    -Name $vmssname `
    -VirtualMachineScaleSet $vmss

# Get information about the scale set
$vmss = Get-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $vmssname

#Create a rule to allow traffic over port 80
$nsgFrontendRule = New-AzNetworkSecurityRuleConfig `
  -Name myFrontendNSGRule `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 200 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access Allow

#Create a network security group and associate it with the rule
$nsgFrontend = New-AzNetworkSecurityGroup `
  -ResourceGroupName  $ResourceGroupName `
  -Location $location `
  -Name myFrontendNSG `
  -SecurityRules $nsgFrontendRule

$vnet = Get-AzVirtualNetwork `
  -ResourceGroupName  $ResourceGroupName `
  -Name $vnet

$frontendSubnet = $vnet.Subnets[0]

$frontendSubnetConfig = Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $vnet `
  -Name mySubnet `
  -AddressPrefix $frontendSubnet.AddressPrefix `
  -NetworkSecurityGroup $nsgFrontend

Set-AzVirtualNetwork -VirtualNetwork $vnet

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
    -ResourceGroupName $ResourceGroupName `
    -Name $vmssname `
    -VirtualMachineScaleSet $vmss

#@ Test Scale Set ##
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Select-Object IpAddress