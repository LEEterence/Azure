<# 
~ Update VMSS site
Source: https://github.com/itorian/VirtualMachineScaleSetAutomationAndDeploymentUsingCustomScriptExtension/blob/master/PowerShell-Custom-Script-Extension-on-VMSS-using-commands-to-re-deploy-or-update-app/start-local.ps1
#>

#$location = "WestUS"
$ResourceGroupName = "SoftwareJuice"
$vmssname = "sj-vmss"
#$vnet = "sj-vnet"

# Define the script for your Custom Script Extension to run on vmss
$publicSettings = @{
    "fileUris" = (,"https://sjstorage123.blob.core.windows.net/vmss/update-azvmss-remote.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File update-azvmss-remote.ps1"
  }
  
  # Get vmss
  $vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $vmssname
  
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