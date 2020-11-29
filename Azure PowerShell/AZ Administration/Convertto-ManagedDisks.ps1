# Standalone VMs
$rgName = "myResourceGroup"
$vmName = "myVM"
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $vmName

# Convert VMs in availability set
$rgName = 'myResourceGroup'
$avSetName = 'myAvailabilitySet'

$avSet = Get-AzAvailabilitySet -ResourceGroupName $rgName -Name $avSetName
Update-AzAvailabilitySet -AvailabilitySet $avSet -Sku Aligned

$avSet.PlatformFaultDomainCount = 2
Update-AzAvailabilitySet -AvailabilitySet $avSet -Sku Aligned

$avSet = Get-AzAvailabilitySet -ResourceGroupName $rgName -Name $avSetName

foreach($vmInfo in $avSet.VirtualMachinesReferences)
{
  $vm = Get-AzVM -ResourceGroupName $rgName | Where-Object {$_.Id -eq $vmInfo.id}
  Stop-AzVM -ResourceGroupName $rgName -Name $vm.Name -Force
  ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $vm.Name
}