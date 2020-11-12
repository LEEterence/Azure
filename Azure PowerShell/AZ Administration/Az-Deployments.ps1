<# 
~ Deploying JSON ARM templates from PS
#>

# Deploying JSON Template
    New-AzResourceGroupDeployment -ResourceGroupName ps10-RG -Name "Deployment1" -TemplateFile .\Storage\example_storage.json
    # * NOTE: The 'Name' parameter is custom - up to the user

# Deploying JSON template with Parameter file
    New-AzResourceGroupDeployment -ResourceGroupName ps10-RG -Name "Deployment1" -TemplateFile .\example_storage.json -TemplateParameterFile .\example_storage_param.json
