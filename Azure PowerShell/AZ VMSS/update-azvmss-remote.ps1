<# 

Source: https://github.com/itorian/VirtualMachineScaleSetAutomationAndDeploymentUsingCustomScriptExtension/blob/master/PowerShell-Custom-Script-Extension-on-VMSS-using-commands-to-re-deploy-or-update-app/re-deploy-app.ps1
#>

# add web server with all features
Add-WindowsFeature -Name Web-Server -IncludeAllSubFeature

# clean www root folder
Remove-Item C:\inetpub\wwwroot\* -Recurse -Force

# download website zip package
$ZipBlobUrl = 'https://sjstorage123.blob.core.windows.net/vmss/AzWebSite-Update.zip'
$ZipBlobDownloadLocation = 'D:\AzWebSite-Update.zip'
(New-Object System.Net.WebClient).DownloadFile($ZipBlobUrl, $ZipBlobDownloadLocation)

# extract downloaded zip
$UnzipLocation = 'C:\inetpub\wwwroot\'
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($ZipBlobDownloadLocation, $UnzipLocation)

# read write permission
$Path = "C:\inetpub\wwwroot\temp"
$User = "IIS AppPool\DefaultAppPool"
$Acl = Get-Acl $Path
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($User, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $Path $Acl