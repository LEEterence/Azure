<# 
~ Custom extension for joining domain - couldn't get JSON template or DSC to work properly, so using this for now

@Changes:
    - Splatted the custom extension
    - Turned code into function
    - Code now queries only running VMs, condition if none found to notify user instead of attempting domain join on each
    - Password and username abstracted
    - Location now based on RGs
    - Added DomainJoinAdminUsername variable which combines domain and username

.Examples Joining all VMs in RG to on-premise domain
Join-DomainExtension -ResourceGroupName sleepygeeks -DomainName sleepygeeks.com -DomainJoinUser Administrator 

References: https://github.com/Azure/azure-powershell/issues/1316
#>
function Join-DomainExtension {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string] $DomainName,

        #[Parameter(Mandatory = $true)]
        #[ValidateNotNullOrEmpty()]
        #[pscredential] $DomainCredential,

        [Parameter(Mandatory = $true)]
        [string]
        $DomainJoinUser,
        
        [Parameter(Mandatory = $true)]
        [SecureString]
        $DomainJoinPassword,
        
        [Parameter(Mandatory = $false)]
        [string] $Location
    )
    $Names = get-azvm -ResourceGroupName Sleepygeeks -status | Where-Object {$_.PowerState -eq "VM Running"} | Select-Object -ExpandProperty Name
    
    if($null -eq $Names){
        Write-Host "No VMs online - must turn on VMs prior to joining the domain." -ForegroundColor Yellow
    }else {
        foreach($Name in $Names){
            #$ResourceGroupName = "SleepyGeeks"
            $VMName = $Name
            #$DomainName = "sleepygeeks.com"
            $Location = (Get-AzResourceGroup -Name $ResourceGroupName).Location
            $DomainJoinAdminUsername = "$DomainName\$DomainJoinUser"
            #$DomainJoinPassword = "Password1"
        
            $ExtensionParam = @{
                VMName              = $VMName
                ResourceGroupName   = $ResourceGroupName
                Name                = "JoinAD" 
                ExtensionType       = "JsonADDomainExtension" 
                Publisher           = "Microsoft.Compute"
                TypeHandlerVersion  = "1.0"
                Location            = $Location
                Settings            = @{ "Name" = $DomainName; "OUPath" = ""; "User" = $DomainJoinAdminUsername; "Restart" = "true"; "Options" = 3}
                ProtectedSettings   = @{"Password" = $DomainJoinPassword}
            }
            Set-AzVMExtension @ExtensionParam -AsJob
        }
    }
}

