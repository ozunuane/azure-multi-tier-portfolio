# resource "azurerm_kubernetes_cluster_node_pool" "custom_nodepool" {
#   count                 = terraform.workspace == "staging" ? 0 : 0
#   name                  = var.dedicated_node_pool_name
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.privateaks.id
#   vm_size               = var.nodepool_vm_size
#   node_count            = var.nodepool_nodes_count
#   min_count             = var.dedicated_np_count_min
#   max_count             = var.dedicated_np_count_max
#   mode                  = "User" # Ensures this is a secondary node pool
#   os_disk_size_gb       = 30
#   vnet_subnet_id        = module.kube_network.subnet_ids["aks-subnet"]
#   orchestrator_version  = data.azurerm_kubernetes_service_versions.current.version_prefix

#   # Optional Labels for workload scheduling
#   node_labels = {
#     "nodepool-type" = "dedicated"
#     "workload"      = "high-performance"
#     "resource"      = "special"
#     "redis-node"    = "true"
#   }

#   # # # Optional Taints (useful for dedicated workloads)
#   # node_taints = [
#   #   "dedicated-node=true:NoSchedule"
#   # ]

#   tags = local.common_tags
# }

