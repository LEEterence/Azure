<# 
~ Custom extension for joining domain - couldn't get JSON template or DSC to work properly, so using this for now

@ Source: https://github.com/Azure/azure-powershell/issues/1316

#>

$ResourceGroupName = "SleepyGeeks"
$VMName = Read-Host "Enter VM Name"
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


#$DomainJoinParam =@{
#    ResourceGroupName “rg1”
#    Name "JsonADDomainExtension"
#    Publisher "Microsoft.Compute"
#    TypeHandlerVersion "1.0"
#    Settings '{ "Name" : "workgroup1", "User" : "domain\test", "Restart" : "false", "Options" : 1}'
#    VMName “testvm”
#    ProtectedSettings '{"Password": "pass"}'
#}
#
#
#Set-AzVMExtension –ResourceGroupName “rg1” -Name "JsonADDomainExtension" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" -Settings '{ "Name" : "workgroup1", "User" : "domain\test", "Restart" : "false", "Options" : 1}' -VMName “testvm” -ProtectedSettings '{"password": "pass"}'