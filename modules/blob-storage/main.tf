
locals {
  private = var.use_private_access ? "private" : "container"
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = var.min_tls_version


  identity {
    type = "SystemAssigned"
  }
}

# Storage Containers
resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.key
  container_access_type = local.private
  storage_account_id    = azurerm_storage_account.main.id
}

# User-Assigned Managed Identity
resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "${var.env}-storage-access-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# # Role Assignment: Storage Blob Data Contributor
# resource "azurerm_role_assignment" "storage_access" {
#   scope                = azurerm_storage_account.main.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
# }

# # Role Assignment: Managed Identity Operator
# resource "azurerm_role_assignment" "aks_identity" {
#   principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
#   role_definition_name = "Managed Identity Operator"
#   scope                = azurerm_user_assigned_identity.storage_identity.id
# }