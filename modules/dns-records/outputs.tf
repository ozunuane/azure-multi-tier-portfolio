output "azurerm_dns_a_record_fqdn" {
  value = [for key, record in azurerm_dns_a_record.this : record.fqdn]
}

output "id" {
  value = [for key, record in azurerm_dns_a_record.this : record.id]
}