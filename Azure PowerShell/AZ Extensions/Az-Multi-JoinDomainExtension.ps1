<# 
~ Custom extension for joining domain - couldn't get JSON template or DSC to work properly, so using this for now

@ Source: https://github.com/Azure/azure-powershell/issues/1316

Changes:
    - Added support for adding multiple Azure VMs
#>
$ResourceGroupName = Read-Host "Enter Resource Group Name"

$Names = get-azvm -ResourceGroupName Sleepygeeks | Select-Object -ExpandProperty Name
foreach($Name in $Names){
    #$ResourceGroupName = "SleepyGeeks"
    $VMName = $Name
    $DomainName = "sleepygeeks.com"
    $Location = "West US"
    $DomainJoinAdminName = $DomainName + "\Administrator"
    $DomainJoinPassword = "Password1"

    Set-AzVMExtension `
    -VMName $VMName `
    –ResourceGroupName $ResourceGroupName `
    -Name "JoinAD" `
    -ExtensionType "JsonADDomainExtension" `
    -Publisher "Microsoft.Compute" `
    -TypeHandlerVersion "1.0" `
    -Location $Location `
    -Settings @{ "Name" = $DomainName; "OUPath" = ""; "User" = $DomainJoinAdminName; "Restart" = "true"; "Options" = 3} `
    -ProtectedSettings @{"Password" = $DomainJoinPassword}
}

#$ResourceGroupName = "SleepyGeeks"
#$VMName = Read-Host "Enter VM Name"
#$DomainName = "sleepygeeks.com"
#$Location = "West US"
#$DomainJoinAdminName = $DomainName + "\Administrator"
#$DomainJoinPassword = "Password1"

#Set-AzVMExtension `
#    -VMName $VMName `
#    –ResourceGroupName $ResourceGroupName `
#    -Name "JoinAD" `
#    -ExtensionType "JsonADDomainExtension" `
#    -Publisher "Microsoft.Compute" `
#    -TypeHandlerVersion "1.0" `
#    -Location $Location `
#    -Settings @{ "Name" = $DomainName; "OUPath" = ""; "User" = $DomainJoinAdminName; "Restart" = "true"; "Options" = 3} `
#    -ProtectedSettings @{"Password" = $DomainJoinPassword}
