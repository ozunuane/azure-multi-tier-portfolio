# Create private DNS zones
resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.domain_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create VNet links for each private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = azurerm_private_dns_zone.this
  name                  = "${each.value.name}-vnet-link" # Unique name for each VNet link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.vnet_id
}