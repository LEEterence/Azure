<# 
~ Disk caching is an alternative to using a more expensive version of storage 
    IE. having to upgrade from Standard HDD to premium SSD 
#>

# Obtain VM
$vm = get-azvm -ResourceGroupName "<RG Name>" -Name "<vm name>"
$datadisk = ($vm.StorageProfile.DataDisks).Name

# Change disk to caching only (note - an ADDITIONAL managed disk must've been created already)
Set-AzVMDataDisk -vm $vm -Name $datadisk -Caching ReadWrite | update-azvm 