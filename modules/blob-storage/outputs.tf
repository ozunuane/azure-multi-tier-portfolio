output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_names" {
  value = [for container in azurerm_storage_container.containers : container.name]
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.storage_identity.id
}
