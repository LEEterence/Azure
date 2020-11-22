#Requires -Module xDSCDomainjoin

Configuration DomainJoinConfiguration
{   
    Import-DscResource -ModuleName 'xDSCDomainjoin'
   
    #domain credentials to be given here   
    $secdomainpasswd = ConvertTo-SecureString "<Password>" -AsPlainText -Force
    $mydomaincreds = New-Object System.Management.Automation.PSCredential("user@contoso.com", $secdomainpasswd)
   
        
    node $AllNodes.NodeName   
    {
        xDSCDomainjoin JoinDomain
        {
            Domain = 'contoso.com'
            Credential = $mydomaincreds
           
        }
    }
}
