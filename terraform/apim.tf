resource "azurerm_api_management" "apim" {
  name                = local.apim_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  publisher_name      = local.apim_publisher_name
  publisher_email     = local.apim_publisher_email

  sku_name = "Developer_1"

  identity {
    type         = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  virtual_network_type = "External"

}