terraform apply -auto-approve
$outputVars = terraform output -json | ConvertFrom-Json

#Deploy the app
az functionapp deployment source config --branch master --manual-integration --name $outputVars.function_name.value --repo-url https://github.com/fortunkam/function-csharp-utils --resource-group $outputVars.spoke_resource_group.value