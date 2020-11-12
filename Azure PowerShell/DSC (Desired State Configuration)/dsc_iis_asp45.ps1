Configuration IISDSC{
    Node 'localhost'{
        # Install IIS
        WindowsFeature IIS{
            Ensure = "Present"
            Name = "Web-Server"
        }
        # Install ASP .NET 4.5
        WindowsFeature ASP{
            Ensure = "Present"
            Name = "Web-ASP-NET45"
        }
    }
}

# Example Publish (then access 'extensions' in the VM within Azure Portal)
#Publish-AzVMDscConfiguration -ConfigurationPath "Path\to\dsc\file.ps1" -OutputArchivePath "Path\to\dsc\file.zip"  
    # Note: no .ps1 in the output - only .zip
    # @ Can also publish to azure blob storage instead of local