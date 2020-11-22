#source: https://github.com/theonlyway/xDSCDomainjoin/blob/master/DSCResources/xDSCDomainjoin/xDSCDomainjoin.psm1
function Get-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Domain,

    [Parameter(Mandatory = $true)]
    [pscredential]$Credential,

    [string]$JoinOU
  )

  #Write-Verbose "Use this cmdlet to deliver information about command processing."

  #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

  $convertToCimCredential = New-CimInstance -ClassName MSFT_Credential -Property @{ Username = [string]$Credential.Username; Password = [string]$null } -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly

  $returnValue = @{
    Domain = (Get-WMIObject win32_computersystem).Domain
    JoinOU = $JoinOU
    Credential = [ciminstance]$convertToCimCredential
  }

  $returnValue
}


function Set-TargetResource
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Domain,

    [Parameter(Mandatory = $true)]
    [pscredential]$Credential,

    [string]$JoinOU
  )

  if ($JoinOU) {
    Add-Computer -DomainName $Domain -Credential $Credential -OUPath $JoinOU -Force
  }
  else {
    Add-Computer -DomainName $Domain -Credential $Credential -Force
  }
  #trigger reboot by DSC LCM
  $global:DSCMachineStatus = 1
}


function Test-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Domain,

    [Parameter(Mandatory = $true)]
    [pscredential]$Credential,

    [string]$JoinOU
  )

  if ($Domain.ToLower() -eq (Get-WmiObject win32_computersystem).Domain) {
    return $true
    }
    else {
      return $false
    }
}

Export-ModuleMember -Function *-TargetResource
