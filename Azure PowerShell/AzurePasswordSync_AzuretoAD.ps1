<# 
Legacy NTLM and Kerberos hashes won't synchronize from Azure to AD (but will sync from AD to Azure)  - enable the following code to adjust this
Source: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-configure-password-hash-sync#enable-synchronization-of-password-hashes
#>

# Define the Azure AD Connect connector names and import the required PowerShell module
$azureadConnector = "Electro9hotmail.onmicrosoft.com - AAD"
$adConnector = "sleepygeeks.com"

Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"
Import-Module "C:\Program Files\Microsoft Azure Active Directory Connect\AdSyncConfig\AdSyncConfig.psm1"

# Optional Code to Verify Connector status
$connector = Get-AdSyncConnector -Name $adConnector

# Create a new ForceFullPasswordSync configuration parameter object then
# update the existing connector with this new configuration
$c = Get-ADSyncConnector -Name $adConnector
$p = New-Object Microsoft.IdentityManagement.PowerShell.ObjectModel.ConfigurationParameter "Microsoft.Synchronize.ForceFullPasswordSync", String, ConnectorGlobal, $null, $null, $null
$p.Value = 1
$c.GlobalParameters.Remove($p.Name)
$c.GlobalParameters.Add($p)
$c = Add-ADSyncConnector -Connector $c

# Disable and re-enable Azure AD Connect to force a full password synchronization
Set-ADSyncAADPasswordSyncConfiguration -SourceConnector $adConnector -TargetConnector $azureadConnector -Enable $false
Set-ADSyncAADPasswordSyncConfiguration -SourceConnector $adConnector -TargetConnector $azureadConnector -Enable $true