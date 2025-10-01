
resource "azurerm_network_security_group" "example" {
  name                = "${var.env}-nsg-rg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "${var.env}-sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags

  # lifecycle {
  #   ignore_changes = all
  # }
}







