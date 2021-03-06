
# Prerequisites - note MUST install-module as admin => Locate Az modules under C:\users\administrator\documents\PowerShell\Modules => Copy and paste into All users directory at C:\Program Files\PowerShell\Modules
Import-Module Az
#Requires -Module Az


function Set-NonInteractiveAuthentication {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        [security.securestring]
        $password,

        [parameter(Mandatory = $true)]
        [string]
        $subscriptionname,

        [parameter(Mandatory = $true)]
        [string]
        $IdentifierURI,

        [parameter(Mandatory = $false)]
        [String]
        $azureAppIDPassFilePath = "C:\AzureAppPassword.txt"
    )
    [string]$password
    [Security.SecureString] $securepass = ConvertTo-SecureString $password -AsPlainText -Force 
    $myApp = New-AzADApplication -DisplayName AppForServicePrincipal -IdentifierUris $IdentifierURI -Password $securepass
        # IdentifierURLs is custom specified
    
    # Create the new service principal. NOTE: it may already assign 'contributor' role already (so the next step isn't necessary)
    $sp = New-AzADServicePrincipal -ApplicationId $myApp.ApplicationId
    
    # (Optional?) Assign a role to the service principal
    New-AzRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ServicePrincipalNames[0]
    
    # Converting encrypted secure password to a text file to enable NONINTERACTIVE AUTHENTICATION
    #$azureAppIDPassFilePath = 'C:\AzureAppPassword.txt'
    $securepass | ConvertFrom-SecureString | Out-File -FilePath $azureAppIDPassFilePath    
    
    # ~Noninteractive Authentication w/ PS Credential Object (remove the necessity to run "Connect-AzAccount")
    # Create PSCredential Object that contains Azure app id and password
    $azureAppCred = (New-Object System.Management.Automation.PSCredential $sp.ApplicationId,(get-content -Path $azureAppIDPassFilePath | ConvertTo-SecureString))
        # NOTE: Converting encrypted password to secure string makes variable unqueryable by get-content!
    
    # Obtaining required parameters 
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionname
    
    # Logging in
    Connect-AzAccount -ServicePrincipal -SubscriptionId $subscription.Id -TenantId $subscription.TenantId -Credential $azureAppCred
    
}

# ~ Enabling authentication
    # Manual Authentication
    #Connect-AzAccount
    #    # Find information for subscription (essential for later commands)
    #    Get-AzSubscription 
    #    # Subscription ID
    #    (Get-AzSubscription -SubscriptionName "Azure for Students").Id
    #    #Tenant ID
    #    (Get-AzSubscription -SubscriptionName "Azure for Students").TenantId
    #    # Select another subscription
    #    Get-AzContext -ListAvailable
    #    Set-AzContext -Name "Azure for Students"

    # Creating service account to automate authentication
    # NOTE: MUST be global admin of the subscription (Azure for Students doesn't give global admin)