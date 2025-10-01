output "ssh_command" {
  value = "ssh ${module.jumpbox.jumpbox_username}@${module.jumpbox.jumpbox_ip}"
}

output "jumpbox_password" {
  description = "Jumpbox Admin Passowrd"
  value       = module.jumpbox.jumpbox_password
  sensitive   = true
}

# output "staging_db_password" {
#   description = "Db Admin Passowrd"
#   value       = module.database_staging.db_pass
#   sensitive   = true
# }



output "kube_config" {
  value = azurerm_kubernetes_cluster.privateaks.kube_config_raw

  sensitive = true
}


