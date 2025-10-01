resource "azurerm_route_table" "rt" {
  name                = var.rt_name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  #   route {
  #     name                   = var.route_name
  #     address_prefix         = "0.0.0.0/0"
  #     next_hop_type          = var.hop_type
  #     next_hop_in_ip_address = var.next_hop_in_ip_address
  #   }
}



resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.rt.id

}

