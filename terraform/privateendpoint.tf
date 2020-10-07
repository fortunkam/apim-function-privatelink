resource "azurerm_private_endpoint" "table" {
  name                = local.storage_data_private_endpoint
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  subnet_id           = azurerm_subnet.data.id

  private_service_connection {
    name                           = local.storage_data_private_link
    private_connection_resource_id = azurerm_storage_account.data.id
    is_manual_connection           = false
    subresource_names = [ "table" ] 
  }
}

resource "azurerm_private_endpoint" "function" {
  name                = local.function_sites_private_endpoint
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  subnet_id           = azurerm_subnet.function.id

  private_service_connection {
    name                           = local.function_sites_private_link
    private_connection_resource_id = azurerm_function_app.function.id
    is_manual_connection           = false
    subresource_names = [ "sites" ] 
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = local.storage_data_blob_private_link
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  subnet_id           = azurerm_subnet.data.id

  private_service_connection {
    name                           = local.storage_data_blob_private_link
    private_connection_resource_id = azurerm_storage_account.data.id
    is_manual_connection           = false
    subresource_names = [ "blob" ] 
  }
}