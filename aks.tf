
resource "azurerm_kubernetes_cluster" "privateaks" {
  name                    = "zaho-${var.env}-private-aks"
  location                = var.location
  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.version_prefix
  resource_group_name     = azurerm_resource_group.kube.name
  dns_prefix              = "zaho-private-aks"
  private_cluster_enabled = true
  sku_tier                = var.aks_cluster_sku_tier
  tags                    = local.common_tags


  default_node_pool {
    name                 = var.node_pool_name
    node_count           = var.nodepool_nodes_count
    vm_size              = var.nodepool_vm_size
    min_count            = var.min_node_count
    max_count            = var.max_node_count
    vnet_subnet_id       = module.kube_network.subnet_ids["aks-subnet"]
    auto_scaling_enabled = var.node_auto_scaling_enabled

  }

  # identity {
  #   # type = "SystemAssigned"

  # }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  network_profile {
    # pod_cidr = var.pod_cidr
    dns_service_ip = var.network_dns_service_ip
    network_plugin = "azure"
    # network_plugin_mode = "overlay"
    outbound_type = "userDefinedRouting"
    service_cidr  = var.network_service_cidr
  }



  ingress_application_gateway {
    gateway_id = terraform.workspace == "staging" ? azurerm_application_gateway.network[0].id : azurerm_application_gateway.production[0].id
  }


  lifecycle {
    ignore_changes = [
      # Ignore changes to these attributes
      default_node_pool[0].node_count,
      default_node_pool[0].upgrade_settings,
      monitor_metrics,
      oms_agent,
      key_vault_secrets_provider,
      web_app_routing
    ]
    # depends_on = [azurerm_application_gateway.network, module.nat_routetable]
  }

}

