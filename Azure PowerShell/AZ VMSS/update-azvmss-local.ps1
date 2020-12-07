<# 
~ Update VMSS site
Source: https://github.com/itorian/VirtualMachineScaleSetAutomationAndDeploymentUsingCustomScriptExtension/blob/master/PowerShell-Custom-Script-Extension-on-VMSS-using-commands-to-re-deploy-or-update-app/start-local.ps1
#>

$location = "WestUS"
$ResourceGroupName = "SoftwareJuice"
$vmssname = "sg-vmss"
$vnet = "sj-vnet"

# Define the script for your Custom Script Extension to run on vmss
$publicSettings = @{
    "fileUris" = (,"https://storageitorian.blob.core.windows.net/re-deploy-app/re-deploy-app.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File re-deploy-app.ps1"
  }
  
  # Get vmss
  $vmss = Get-AzVmss -ResourceGroupName $resourcegroup -VMScaleSetName $vmssname
  
  # Remove extension
  $extensionname = "CustomScript"
  Remove-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extensionname
  Update-AzVmss -ResourceGroupName $resourcegroup -Name $vmssname -VirtualMachineScaleSet $vmss
  
  # Use Custom Script Extension to deploy mvc/asp.net website
  Add-AzVmssExtension `
    -VirtualMachineScaleSet $vmss `
    -Name $extensionname `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings
  
  # Update the VMSS model
  Update-AzVmss -ResourceGroupName $resourcegroup -Name $vmssname -VirtualMachineScaleSet $vmss