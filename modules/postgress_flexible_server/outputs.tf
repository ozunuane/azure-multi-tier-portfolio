output "db_pass" {
  value = random_password.adminpassword.result[*]
}

output "server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}