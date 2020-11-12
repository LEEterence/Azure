# @ Deploy a simple windows VM
New-AzResourceGroupDeployment -ResourceGroupName "AZ104-RG" -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-windows/azuredeploy.json

# More options
New-AzVm `
    -ResourceGroupName "SL-PowershellVM" `
    -Name "vmpshell01" `
    -Location "Canada Central" `
    -VirtualNetworkName "pshellVnet" `
    -SubnetName "pshellSubnet" `
    -SecurityGroupName "pshellNetworkSecurityGroup" `
    -PublicIpAddressName "pshellPublicIpAddress" `
    -OpenPorts 80,3389 `
    -Size Standard_B2s