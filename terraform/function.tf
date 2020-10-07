resource "azurerm_app_service_plan" "appplan" {
  name                = local.app_plan
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  sku {
    tier = "PremiumV2"
    size = "P1V2"
  }
}

resource "azurerm_function_app" "function" {
  name                = local.function
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id
  storage_account_name = azurerm_storage_account.data.name
  storage_account_access_key = azurerm_storage_account.data.primary_access_key
  version = "~3"

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

  site_config {
    scm_use_main_ip_restriction = false
    ip_restriction {
      ip_address = "${lookup(jsondecode(data.http.httpbin.body), "origin")}/32"
    }

    scm_ip_restriction {
      ip_address = "${lookup(jsondecode(data.http.httpbin.body), "origin")}/32"
    }

    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.apim.id
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "function" {
  app_service_id = azurerm_function_app.function.id
  subnet_id      = azurerm_subnet.function_se.id
}