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

function Install-IISExtension {
  #param (
  #  OptionalParameters
  #)
  ## Install IIS
  Write-Verbose "Installing IIS..."
  for($x = 1;$x -lt 3;$x++){

  }
  $PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server -IncludeManagementTools"}'
  
  $IISParams = @{
      ExtensionName       = "IIS"
      ResourceGroupName   = $ResourceGroupName
      VMName              = "$($vm.Name)$x"
      Publisher           = "Microsoft.Compute"
      ExtensionType       = "CustomScriptExtension"
      TypeHandlerVersion  =  1.4
      SettingString       = $PublicSettings
      Location            = $Location
  }
  Set-AzVMExtension @IISParams
  
}