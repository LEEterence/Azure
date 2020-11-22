<# 
~ Check price of VMs
    - useful for 
#>

Get-AzVM -ResourceGroupName $resourceGroup | Select-Object Name,@{Name="maxPrice"; Expression={$_.BillingProfile.MaxPrice}}