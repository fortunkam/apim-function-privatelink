terraform apply -auto-approve
$outputVars = terraform output -json | ConvertFrom-Json

#Deploy the app
az webapp deployment source config --branch master --manual-integration --name $outputVars.website_name.value --repo-url https://github.com/fortunkam/simple-node-express-app --resource-group $outputVars.spoke_resource_group.value