
locals {
  vnet_resource_group_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}//resourceGroups/${var.kube_resource_group_name}"
  kubenet_resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}//resourceGroups/${var.vnet_resource_group_name}"

}

resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.env}-user-identity"
  location            = azurerm_resource_group.kube.location
  resource_group_name = azurerm_resource_group.kube.name
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "${var.env}-aks-workload-id"
  resource_group_name = azurerm_kubernetes_cluster.privateaks.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.issuer_uri
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = "system:serviceaccount:${var.env}:zaho-sa-${var.env}"

  depends_on = [azurerm_kubernetes_cluster.privateaks]
}


# resource "azurerm_role_assignment" "netcontributor" {
#   role_definition_name = "Network Contributor"
#   scope                = module.kube_network.subnet_ids["aks-subnet"]
#   principal_id         = azurerm_user_assigned_identity.this.principal_id
#   lifecycle {
#     ignore_changes = all
#   }
# }

# resource "azurerm_role_assignment" "netcontributor_apigw" {
#   role_definition_name = "Network Contributor"
#   scope                = module.kube_network.subnet_ids["api-gw-subnet"]
#   principal_id         = azurerm_user_assigned_identity.this.principal_id

# }




# resource "azurerm_role_assignment" "agic_subnet" {
#   principal_id   = data.azurerm_user_assigned_identity.agic_identity.principal_id # Replace with AGIC identity
#   role_definition_name = "Contributor"
#   scope          = azurerm_subnet.api_gw_subnet.id
# }


# resource "azurerm_role_assignment" "rsgkube" {
#   scope                = local.kubenet_resource_group_id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.this.principal_id
# }


# resource "azurerm_role_assignment" "rsgvnet" {
#   scope                = local.vnet_resource_group_id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.this.principal_id
# }



