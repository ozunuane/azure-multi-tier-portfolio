output "domain_names" {
  value = azurerm_private_dns_zone.this[*]
}

