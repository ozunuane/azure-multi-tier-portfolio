resource "azurerm_route_table" "rt" {
  name                = var.rt_name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  route {
    name           = "AllowAzureAPI"
    address_prefix = "AzureCloud"
    next_hop_type  = "Internet"
  }

  route {
    name           = "AllowAKSTraffic"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}


resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.rt.id

}

