resource "azurerm_private_dns_zone" "table" {
  name                = local.storage_table_dns_zone
  resource_group_name = azurerm_resource_group.spoke.name
  depends_on = [azurerm_storage_account.data]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = local.storage_data_dns_link_hub
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  name                  = local.storage_data_dns_link_spoke
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

resource "azurerm_private_dns_a_record" "storage" {
  name                = azurerm_storage_account.data.name
  zone_name           = azurerm_private_dns_zone.table.name
  resource_group_name = azurerm_resource_group.spoke.name
  ttl                 = 300
  records             = [ azurerm_private_endpoint.table.private_service_connection[0].private_ip_address ]
}

resource "azurerm_private_dns_zone" "function" {
  name                = local.function_sites_dns_zone
  resource_group_name = azurerm_resource_group.spoke.name
  depends_on = [azurerm_function_app.function]
}

resource "azurerm_private_dns_a_record" "function" {
  name                = azurerm_function_app.function.name
  zone_name           = azurerm_private_dns_zone.function.name
  resource_group_name = azurerm_resource_group.spoke.name
  ttl                 = 300
  records             = [ azurerm_private_endpoint.function.private_service_connection[0].private_ip_address ]
}

resource "azurerm_private_dns_a_record" "function_scm" {
  name                = "${azurerm_function_app.function.name}.scm"
  zone_name           = azurerm_private_dns_zone.function.name
  resource_group_name = azurerm_resource_group.spoke.name
  ttl                 = 300
  records             = [ azurerm_private_endpoint.function.private_service_connection[0].private_ip_address ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "function_spoke" {
  name                  = local.function_sites_dns_link_spoke
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.function.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "function_hub" {
  name                  = local.function_sites_dns_link_hub
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.function.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone" "blob" {
  name                = local.storage_blob_dns_zone
  resource_group_name = azurerm_resource_group.spoke.name
  depends_on = [azurerm_storage_account.data]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_blob" {
  name                  = local.storage_data_blob_dns_link_hub
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_blob" {
  name                  = local.storage_data_blob_dns_link_spoke
  resource_group_name   = azurerm_resource_group.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

resource "azurerm_private_dns_a_record" "blob" {
  name                = azurerm_storage_account.data.name
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.spoke.name
  ttl                 = 300
  records             = [ azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address ]
}