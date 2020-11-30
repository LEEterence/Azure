<# 
~ Custom AZ extension for installing IIS
#>
# Install IIS
$Location = "westus"

$PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server -IncludeManagementTools"}'

Set-AzVMExtension -ExtensionName "IIS" -ResourceGroupName "RG1" -VMName "AZVM1" `
  -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.4 `
  -SettingString $PublicSettings -Location $location

## Splatting ##

function FunctionName {
  #param (
  #  OptionalParameters
  #)
  ## Install IIS
  Write-Verbose "Installing IIS..."
  $PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server -IncludeManagementTools"}'
  
  $IISParams = @{
      ExtensionName       = "IIS"
      ResourceGroupName   = $ResourceGroupName
      VMName              = $vm.Name
      Publisher           = "Microsoft.Compute"
      ExtensionType       = "CustomScriptExtension"
      TypeHandlerVersion  =  1.4
      SettingString       = $PublicSettings
      Location            = $Location
  }
  Set-AzVMExtension @IISParams
  
}