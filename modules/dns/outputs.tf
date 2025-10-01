output "domain_names" {
  value = azurerm_dns_zone.public[*]
}

# output "dns_zone_name" {
#   value = azurerm_dns_zone.public.name[*]
# }