
<# 
Source: https://github.com/adbertram/PowerShellForSysadmins/blob/master/Part%20II/Controlling%20the%20Cloud/New-CustomAzVm.ps1

@ REMINDERS: 
    1. Must be in the SAME LOCATION
    2. Public IP and Virtual NIC MUST be DIFFERENT (everything else can stay the same)
#>

function New-CustomAzVM {
    [CmdletBinding()]
    param
    (
        # Existing RG: enter existing RG
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$VmName,

        [Parameter(Mandatory)]
        [string]$HostName,

        # Existing RG: Can create new subnet or use existing
        [Parameter(Mandatory)]
        [string]$SubnetName,

        [Parameter(Mandatory)]
        [string]$VirtualNicName,

        # Existing RG: enter existing Virtual Network
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$VirtualNetworkName,

        [Parameter(Mandatory)]
        [string]$PublicIpAddressName,

        [Parameter(Mandatory)]
        [ValidateSet('Static', 'Dynamic')]
        [string]$PublicIpAddressAllocationMethod,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$AdminCredential,

        [Parameter()]
        [string]$Location = 'Canada Central',

        [Parameter()]
        [string]$VmSize = 'Standard_B2s',
        
        # Change as necessary
        [Parameter()]
        [string]$SubnetAddressPrefix = '10.0.1.0/24',

        [Parameter()]
        [string]$VirtualNetworkAddressPrefix = '10.0.0.0/16',

        # Existing RG: can use existing storage account - IF NEW, MUST BE UNIQUE
        [Parameter(Mandatory)]
        [string]$StorageAccountName,

        [Parameter()]
        [string]$StorageAccountType = 'Standard_LRS',

        [Parameter()]
        [string]$OsDiskName = 'OSDisk'
    )

    if (Get-AzVm -Name $VmName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore) {
        Write-Verbose -Message "The Azure virtual machine [$($VmName)] already exists."
    } else {
        if (-not (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Ignore)) {
            Write-Verbose -Message "Creating an Azure resource group with the name [$($ResourceGroupName)]..."
            $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        } else {
            Write-Verbose -Message "Azure resource group with the name [$($ResourceGroupName)] already exists."
        }

        if (-not ($vNet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore)) {
            $newSubnetParams = @{
                'Name'          = $SubnetName
                'AddressPrefix' = $SubnetAddressPrefix
            }
            $subnet = New-AzVirtualNetworkSubnetConfig @newSubnetParams

            $newVNetParams = @{
                'Name'              = $VirtualNetworkName
                'ResourceGroupName' = $ResourceGroupName
                'Location'          = $Location
                'AddressPrefix'     = $VirtualNetworkAddressPrefix
            }
            Write-Verbose -Message "Creating virtual network name [$($VirtualNetworkName)]..."
            $vNet = New-AzVirtualNetwork @newVNetParams -Subnet $subnet
        } else {
            Write-Verbose -Message "The virtual network [$($VirtualNetworkName)] already exists."
        }

        if (-not ($publicIp = Get-AzPublicIpAddress -Name $PublicIpAddressName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore)) {
            $newPublicIpParams = @{
                'Name'              = $PublicIpAddressName
                'ResourceGroupName' = $ResourceGroupName
                'AllocationMethod'  = $PublicIpAddressAllocationMethod
                'Location'          = $Location
            }
            Write-Verbose -Message "Creating the public IP address [$($PublicIpAddressName)].."
            $publicIp = New-AzPublicIpAddress @newPublicIpParams
        } else {
            Write-Verbose -Message "The public IP address [$($PublicIpAddressName)] already exists."
        }

        if (-not ($vNic = Get-AzNetworkInterface -Name $VirtualNicName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore)) {
            $newVNicParams = @{
                'Name'              = $VirtualNicName
                'ResourceGroupName' = $ResourceGroupName
                'Location'          = $Location
                'SubnetId'          = $vNet.Subnets[0].Id
                'PublicIpAddressId' = $publicIp.Id
            }
            Write-Verbose -Message "Creating the virtual NIC [$($VirtualNicName)]..."
            $vNic = New-AzNetworkInterface @newVNicParams
        } else {
            Write-Verbose -Message "The virtual NIC [$($VirtualNicName)] already exists."
        }

        if (-not ($storageAccount = (Get-AzStorageAccount).where({ $_.StorageAccountName -eq $StorageAccountName }))) {
            $newStorageAcctParams = @{
                'Name'              = $StorageAccountName
                'ResourceGroupName' = $ResourceGroupName
                'Type'              = $StorageAccountType
                'Location'          = $Location
            }
            Write-Verbose -Message "Creating the storage account [$($StorageAccountName)]..."
            $storageAccount = New-AzStorageAccount @newStorageAcctParams
        } else {
            Write-Verbose -Message "The storage account [$($StorageAccountName)] already exists."
        }

        $newConfigParams = @{
            'VMName' = $VmName
            'VMSize' = $VmSize
            'Priority' = "Spot"
            'MaxPrice' = -1
            'EvictionPolicy' = Deallocate
            #New-AzVMConfig -VMName $vmName -VMSize Standard_D1 -Priority "Spot" -MaxPrice -1 -EvictionPolicy Deallocate
        }
        $vmConfig = New-AzVMConfig @newConfigParams

        $newVmOsParams = @{
            'Windows'          = $true
            'ComputerName'     = $HostName
            'Credential'       = $AdminCredential
            'EnableAutoUpdate' = $true
            'VM'               = $vmConfig
        }
        $vm = Set-AzVMOperatingSystem @newVmOsParams

        $offer = Get-AzVMImageOffer -Location $Location –PublisherName 'MicrosoftWindowsServer' | Where-Object { $_.Offer -eq 'WindowsServer' }
        $newSourceImageParams = @{
            'PublisherName' = 'MicrosoftWindowsServer'
            'Version'       = 'latest'
            'Skus'          = '2016-Datacenter'
            'VM'            = $vm
            'Offer'         = $offer.Offer
        }
        $vm = Set-AzVMSourceImage @newSourceImageParams

        $osDiskUri = '{0}vhds/{1}{2}.vhd' -f $storageAccount.PrimaryEndpoints.Blob.ToString(), $VmName, $OsDiskName
        Write-Verbose -Message "Creating OS disk [$($OSDiskName)]..."
        $vm = Set-AzVMOSDisk -Name $OSDiskName -CreateOption 'fromImage' -VM $vm -VhdUri $osDiskUri

        Write-Verbose -Message 'Adding vNic to VM...'
        $vm = Add-AzVMNetworkInterface -VM $vm -Id $vNic.Id

        Write-Verbose -Message "Creating virtual machine [$($VMName)]..."
        New-AzVM -VM $vm -ResourceGroupName $ResourceGroupName -Location $Location

        if (-not(Get-AzVM -Name $vm.Name)){
            Write-Host "$($vm.Name) has failed deployment" -ForegroundColor Red
        }else {
            Write-Host "$($vm.Name) has been created successfully" -ForegroundColor Green
            Get-AzPublicIpAddress -ResourceName $PublicIpAddressName | Select-Object Name,IpAddress

            $RDP = Read-Host "RDP to the host (Y/N)?"
            if($RDP.ToUpper() -eq 'Y'){
                $vm | Get-AzRemoteDesktopFile -ResourceGroupName $ResourceGroupName -Launch
            }
        }
    }
}