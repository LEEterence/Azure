<# 
~ Deploying multiple web servers - using code from New-CustomAzVM_V2 and CustomExtension-IIS

@ REMINDERS: 
    1. Must be in the SAME LOCATION
    2. Public IP and Virtual NIC MUST be DIFFERENT for each VM instance(everything else can stay the same)

Summary: each VM will require unique:
    - VMName/Hostname
    - Virtual NIC
    - Not unique - but each VM will require its own IIS install then Domain Join

    Features: 
        - Prefix prompt
        - Availability Set
        - IIS install
        - Domain Join (NOTE: VPN S2S has to be existing and functioning)

    1. Configure For Loops for multiple VM creation
    2. Add to availability set
    3. Add IIS extension + For loops
    4. Domain Join
    5. (Plan) Join to load balancer - might do this manually. I have to create an excel spreadsheet of list of all resources, vnets, subnets, public IPs, etc. and how they relate to each other.

Source: 
https://github.com/adbertram/PowerShellForSysadmins/blob/master/Part%20II/Controlling%20the%20Cloud/New-CustomAzVm.ps1
https://docs.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-powershell?tabs=option-1-create-load-balancer-basic#configure-virtual-network---standard

Example: 
New-IISWebServers -ResourceGroupName sleepygeeks -VmName SG-AZWEB -HostName SG-AZWEB1 -SubnetName sleepygeeks-subnet -VirtualNicName sg-webnic -VirtualNetworkName sleepygeeks-vnet -AdminCredential azureuser -verbose

    @Changes
        - Remove mandatory public ip address & storage account requirements
        - added for loop to uniquely name VNics and VMs
#>

function New-IISWebServers {
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

        [Parameter()]
        [string]$PublicIpAddressName,

        [Parameter()]
        [ValidateSet('Static', 'Dynamic')]
        [string]$PublicIpAddressAllocationMethod,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$AdminCredential,

        [Parameter()]
        [string]$Location = 'West US',

        [Parameter()]
        [string]$VmSize = 'Standard_B1ms',
        
        # Change as necessary
        [Parameter()]
        [string]$SubnetAddressPrefix = '10.0.1.0/24',

        [Parameter()]
        [string]$VirtualNetworkAddressPrefix = '10.0.0.0/16',

        # Existing RG: can use existing storage account - IF NEW, MUST BE UNIQUE
        [Parameter()]
        [string]$StorageAccountName,

        [Parameter()]
        [string]$StorageAccountType = 'Standard_LRS',

        [Parameter()]
        [string]$OsDiskName = 'OSDisk'
    )
    
    # Create Resource Group or use existing
    if (-not (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Ignore)) {
        Write-Verbose -Message "Creating an Azure resource group with the name [$($ResourceGroupName)]..."
        $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    } else {
        Write-Verbose -Message "Azure resource group with the name [$($ResourceGroupName)] already exists."
    }
    
    # Create Virtual Network or use existing
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
    
    # Create Storage account or Use existing storage account
    #if (-not ($storageAccount = (Get-AzStorageAccount).where({ $_.StorageAccountName -eq $StorageAccountName }))) {
    #    $newStorageAcctParams = @{
    #        'Name'              = $StorageAccountName
    #        'ResourceGroupName' = $ResourceGroupName
    #        'Type'              = $StorageAccountType
    #        'Location'          = $Location
    #    }
    #    Write-Verbose -Message "Creating the storage account [$($StorageAccountName)]..."
    #    $storageAccount = New-AzStorageAccount @newStorageAcctParams
    #} else {
    #    Write-Verbose -Message "The storage account [$($StorageAccountName)] already exists."
    #}
    
    for ($x = 1;$x -lt 3;$x++){
        if (Get-AzVm -Name "$VmName$x" -ResourceGroupName $ResourceGroupName -ErrorAction Ignore) {
            Write-Verbose -Message "The Azure virtual machine [$("$VmName$x")] already exists."
        }else{
            # Create unique NICs for each VM
            if (-not ($vNic = Get-AzNetworkInterface -Name "$VirtualNicName$x" -ResourceGroupName $ResourceGroupName -ErrorAction Ignore)) {
                $newVNicParams = @{
                    'Name'              = "$VirtualNicName$x"
                    'ResourceGroupName' = $ResourceGroupName
                    'Location'          = $Location
                    'SubnetId'          = $vNet.Subnets[0].Id
                    #'PublicIpAddressId' = $publicIp.Id
                }
                Write-Verbose -Message "Creating the virtual NIC [$("$VirtualNicName$x")]..."
                $vNic = New-AzNetworkInterface @newVNicParams
            } else {
                Write-Verbose -Message "The virtual NIC [$("$VirtualNicName$x")] already exists."
            }
        
            $newConfigParams = @{
                'VMName' = "$vmname$x"
                'VMSize' = $VmSize
            }
            $vmConfig = New-AzVMConfig @newConfigParams
        
            $newVmOsParams = @{
                'Windows'          = $true
                'ComputerName'     = "$HostName$x"
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
            #$osDiskUri = '{0}vhds/{1}{2}.vhd' -f $storageAccount.PrimaryEndpoints.Blob.ToString(), "$vmname$x", $OsDiskName
            #Write-Verbose -Message "Creating OS disk [$($OSDiskName)]..."
            #$vm = Set-AzVMOSDisk -Name $OSDiskName -CreateOption 'fromImage' -VM $vm -VhdUri $osDiskUri
        
            Write-Verbose -Message 'Adding vNic to VM...'
            $vm = Add-AzVMNetworkInterface -VM $vm -Id $vNic.Id
        
            Write-Verbose -Message "Creating virtual machine [$("$vmname$x")]..."
            New-AzVM -VM $vm -ResourceGroupName $ResourceGroupName -Location $Location
        
            if (-not(Get-AzVM -Name $vm.Name)){
                Write-Host "$($vm.Name) has failed deployment" -ForegroundColor Red
            }else {
                Write-Host "$($vm.Name) has been created successfully" -ForegroundColor Green
                #Get-AzPublicIpAddress -ResourceName $PublicIpAddressName | Select-Object Name,IpAddress
        
                #$RDP = Read-Host "RDP to the host (Y/N)?"
                #if($RDP.ToUpper() -eq 'Y'){
                #    $vm | Get-AzRemoteDesktopFile -ResourceGroupName $ResourceGroupName -Launch
                #}
            }
        }
    }
}
