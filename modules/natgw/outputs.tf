output "nat_ip" {
  value = azurerm_public_ip.pip.ip_address
}


output "nat_id" {
  value = azurerm_nat_gateway.this.id
}