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