# Accessing Azure AD (Note - I could only access from PS 5 or directly from Azure PS on the portal)
    Install-Module AzureAD
    Import-Module AzureAD
    # Run the following before access to Azure AD cmdlets can be granted
    Connect-AzureAD


# Azure AD Users
    # Obtaining all users
    Get-AzureADUser
    #Creating New User
    $userspassword = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $userspassword.Password = "Password1"

    New-AzureADUser -DisplayName "John Wick" -GivenName "John" -AccountEnabled $false -Surname "Wick" -PasswordProfile $userspassword -UserPrincipalName JohnWick@terencelee.ca -MailNickName "JohnWick"
        # NOTE: -MailNickName is required and CANNOT HAVE SPACES

    #Verify 
    Get-AzureADUser -Filter "startswith(displayname,'John')"

# Azure AD Groups
    #New Group
    New-AzADGroup -DisplayName "SysAdmins" -MailNickname "SysAdmins"
    #Add user to group
    Add-AzADGroupMember -MemberUserPrincipalName "johnwick@terencelee.ca" -TargetGroupDisplayName "Sysadmins"
    # Verify
    Get-AzADGroupMember -GroupDisplayName sysadmins
    
# Azure Resource Groups
    New-AzResourceGroup -Name "AZ104-RG" -Location 'westus'
    # Setting locks
    New-AzResourceLock -LockName "NoDelete" -LockLevel donotdelete -ResourceGroupName "AZ104-RG"

# Modifying VMs
    # Changing VM properties
    $vm = Get-AzVM -Name "simple-vm"
    # Obtaining VM size
    $vm.HardwareProfile.VmSize
    # Obtain allowed VM Sizes
    Get-AzComputeResourceSku | Where-Object {$_.Locations -icontains "westus"}
    # NOTE: May be better to stop the VM first before updating: $Vm | stop-azvm then $vm | start-azvm
    $vm.HardwareProfile.VmSize = "Standard_B2s"
    Update-AzVM -VM $vm -ResourceGroupName az104-RG

# Deleting Resources
    # Cleaning up VMs
    Remove-AzVM -ResourceGroupName Az104-RG -Name simple-vm

# Scale Sets
    Get-AzVmss 

# Managing virtual networks
    Get-AzVirtualNetwork 
    # Obtain Virtual Network Address Space
    Get-AzVirtualNetwork | Select-Object -Property Name -ExpandProperty AddressSpace 
    # Obtain name of Virtual network and its subnets
    Get-AzVirtualNetwork | Select-Object name,subnets,Id
    # Obtain name of subnets for a specific virtual network and subnet prefixes
    Get-AzVirtualNetwork -name VNet-AzureVMsWestUS2 | Select-Object -ExpandProperty subnets | Select-Object Name, Subnet, AddressPrefix

# Obtaining Providers and Provider resources
    # List Providers registration 
    Get-AzResourceProvider -ListAvailable | Select-Object ProviderNamespace,RegistrationState 
    # Provider resources
    Get-AzResourceProvider -ProviderNamespace Microsoft.Compute