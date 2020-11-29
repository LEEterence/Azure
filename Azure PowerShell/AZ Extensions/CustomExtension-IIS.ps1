# Install IIS
$Location = "westus"

$PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server -IncludeManagementTools"}'

Set-AzVMExtension -ExtensionName "IIS" -ResourceGroupName "RG1" -VMName "AZVM1" `
  -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.4 `
  -SettingString $PublicSettings -Location $location
