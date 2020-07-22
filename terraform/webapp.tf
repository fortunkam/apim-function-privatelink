resource "azurerm_app_service_plan" "appplan" {
  name                = local.app_plan
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  sku {
    tier = "PremiumV2"
    size = "P1V2"
  }
}

resource "azurerm_app_service" "website" {
  name                = local.website
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL"         = "1"
    "WEBSITE_DNS_SERVER"         = local.azure_dns_server
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "10.15.2"
    "STORAGE_ACCOUNT"                = azurerm_storage_account.data.name
    "STORAGE_KEY"                    = azurerm_storage_account.data.primary_access_key
    "TABLE_NAME"                     = local.storage_data_table_name
  }

  depends_on = [azurerm_application_gateway.appgateway]

}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp" {
  app_service_id = azurerm_app_service.website.id
  subnet_id      = azurerm_subnet.web_se.id
}