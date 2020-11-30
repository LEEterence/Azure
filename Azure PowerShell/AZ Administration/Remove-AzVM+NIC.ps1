


try{
    $vm = Read-host "Enter VM Name"
    Get-AzVM -Name $vm
    $interface = Get-AzNetworkInterface | Where-object {$_.VirtualMachine -eq $null}
    Remove-AzVM $vm -force
    Remove-AzNetworkInterface $interface -force
}
catch
{
    Write-host "VM with the name $vm doesn't exist."
}