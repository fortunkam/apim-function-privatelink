# Install a Function with a Private Endpoint with outbound traffic routed through a Firewall and inbound traffic coming through an API Management Instance.

## Run the Terraform script
In the /terraform folder are a selection of tf files.  You will need to have terraform installed (I am running v0.12.24 on Powershell Core 7).
run `terraform init` in a powershell prompt and then run the [setup powershell script here](./terraform/setup.ps1), this script runs the `terraform apply` and then deploys the sample app to the function.
The resource prefix and the location are defined as [variables](./terraform/variables.tf) and you should provide new values (particularly for the prefix). 
The resources can be cleaned up by running `terraform destroy`

## What is the script doing?

![What gets deployed!](/diagrams/What%20gets%20deployed.png "What gets deployed")
The script will create 
- 2 resource groups
- 2 virtual networks (peered)
- 6 subnets
- A storage account with table and blob storage accessible via a private endpoint
- private DNS zones to allow resolution of the storage and function private endpoints
- A Function (and app service plan) running a C# application, public access is restricted via the private endpoint, only resources on the vnet (or peered vnet) can access the resource.
- A Firewall that all outbound network traffic is routing through
- An API Management Instance that is public facing and connected to the vnet (the APIM isn't configured to point at the function but can be).
- A VM connected to the hub network with a public IP (in case you need to check the function resources on the vnet)

Note: The storage account also has a private endpoint for blob storage.  This is because a storage account is required by the function app to store secrets and state. By using the private endpoint it can access this storage prviately.

## How does the inbound traffic get routed to my function

![Inbound traffic routing](/diagrams/inbound%20calls.png "inbound calls")

1. A request comes into the API Management instance (APIM) public ip address.  
2. APIM uses the private DNS zone to resolve the function name.
3. The private DNS zone resolves to an internal address for the function.
3. The Application gateway relays the call to the function over the vnet.

## How are internet calls from my website routed?

![outbound internet traffic routing](/diagrams/outbound%20calls%20to%20internet.png "outbound internet traffic routing")

The application that gets deployed makes calls to http://httpbin.org/ip to retrieve the outbound ip of the server making the call.
By default a website with a vnet intergration will always go direct for outbound internet calls (using the app service shared outbound ips).  By adding the `WEBSITE_VNET_ROUTE_ALL=1` setting it will use the UDR applied to the subnet.

1. The website has a private endpoint nic allocated to the function subnet.  
2. The function_se subnet contains a UDR that routes all traffic to the Azure Firewall.
3. The firewall contains application rules that allow traffic to httpbin.org (for the running application), github, nuget and npm (for the application build).

The `GetOutboundIp` function on the website shows the call to httpbin.org/ip is successful and should also return the IP address of the firewall showing the request has been routed.

## How are internet calls to my table storage routed (private endpoint)?

![outbound private endpoint routing](/diagrams/outbound%20calls%20to%20private%20endpoint.png "outbound private endpoint routing")

1. Website requests a MYSTORAGE.table.core.windows.net address.  By default this would resolve to the public ip address (which is locked down)
2. The function is configured to point it's DNS requests at the internal azure DNS Server 168-63-129-16. (https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16). This uses the new `WEBSITE_DNS_SERVER` app setting in the web app (https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)
3. The Azure DNS is aware of our Private DNS Zone so forwards the request there.
4. The private DNS zone is configured to resolve the privatelink address to an ip address on the vnet.
5. The function can now communicate directly with the storage account over the private endpoint ip address.
