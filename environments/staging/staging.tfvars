location                  = "westeurope"
vnet_resource_group_name  = "staging-networks-rg"
hub_vnet_name             = "hub1-firewalvnet"
kube_vnet_name            = "staging-kubevnet"
kube_resource_group_name  = "staging-kubernetes-rg"
nodepool_nodes_count      = 4
nodepool_vm_size          = "Standard_D2_v2"
min_node_count            = 3
max_node_count            = 20
node_auto_scaling_enabled = true
dedicated_np_count_min    = 1
dedicated_np_count_max    = 1

### VPC IP'S ###
hub_address_space        = ["100.21.0.0/22"]
hub_address_space_string = "100.21.0.0/22"

####### BASTION #######
bastion_vm_size              = "Standard_B2s"
bastion_storage_account_type = "StandardSSD_LRS"


##Subnets
jumpbox-subnet                = ["100.21.1.0/24"]
AzureFirewallSubnet           = ["100.21.0.0/24"]
api-gw-subnet                 = ["100.21.3.0/24"]
AzureFirewallManagementSubnet = ["100.21.2.0/24"]

### Kubernetes cluster  Vpc ###
kube_address_space        = ["100.21.4.0/22"]
kube_address_space_string = "100.21.4.0/22"
aks-subnet                = ["100.21.5.0/24"]
apigateway_sku            = "Standard_v2"
apigateway_tier           = "Standard_v2"
apigateway_capacity       = 2

pod_cidr                   = "192.168.0.0/16"
aks_cluster_sku_tier       = "Standard"
network_docker_bridge_cidr = "172.16.0.1/16"
network_dns_service_ip     = "10.2.0.10"
network_service_cidr       = "10.2.0.0/24"
node_pool_name             = "stagingnodes"
dedicated_node_pool_name   = "stgdedicated"
firewall_sku_name          = "AZFW_VNet"
firewall_sku_tier          = "Basic"
env                        = "staging"
kube_version_prefix        = "1.31"

##DATABASE ##
pg_server_name = "test-staging-db"


### PUBLIC DOMAIN NAMES ##
domain_names = [
  "zaho.ng"
]


zone_test_record_names = [
  "web-admin-staging",
  "test-general-apigateway-service-staging",
  "monitoring-staging",
  "web-life-staging",
  "test-life-apigateway-service-staging",
  "agency-base-apigw-staging",
  "agency-uat-staging",
  "agency-staging",
  "test-shared-payments-staging"
]


#### Private Storage Accounts ####
private_storage_account_name = "teststagingbuckets"
private_containers = [
  "media",

]



#### Public Storage Accounts ####
public_storage_account_name = "testbuckets"
public_containers = [
  "media",
  "documents",
  "logs"
]
