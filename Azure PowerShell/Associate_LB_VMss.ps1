<# 
~ Associate new vmss with existing load balancer

Source: https://docs.microsoft.com/en-us/azure/load-balancer/configure-vm-scale-set-powershell
#>
function Existing_LB {
    param (
        # Parameter help description
        [Parameter(AttributeValues)]
        [String]
        $rsg,
        [Parameter(AttributeValues)]
        [String]
        $loc,
        [Parameter(AttributeValues)]
        [String]
        $vms,
        [Parameter(AttributeValues)]
        [String]
        $vnt,
        [Parameter(AttributeValues)]
        [String]
        $sub,
        [Parameter(AttributeValues)]
        [String]
        $lbn,
        [Parameter(AttributeValues)]
        [String]
        $pol
    )
    $lb = Get-AzLoadBalancer -ResourceGroupName $rsg -Name $lbn

    $lb_params=@{
        rsg = "aadds-rg"
        loc = "canada central"
        vms = "aadds-vmss"
        vnt = "aadds-vnet"
        sub = "aadds-defaultsubnet"
        lbn = "aadds-vmss-lb"
        lb  = $lb
        pol = "automatic"
    }
    
    New-AzVmss @lb_params -Verbose
}

$rsg = "aadds-rg"
$loc = "canada central"
$vms = "aadds-vmss"
$vnt = "aadds-vnet"
$sub = "aadds-defaultsubnet"
$lbn = "aadds-vmss-lb"
$pol = "automatic"

$lb = Get-AzLoadBalancer -ResourceGroupName $rsg -Name $lbn

New-AzVmss -ResourceGroupName $rsg -Location $loc -VMScaleSetName $vms -VirtualNetworkName $vnt -SubnetName $sub -LoadBalancerName $lb -UpgradePolicyMode $pol -Verbose