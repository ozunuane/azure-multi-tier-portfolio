location                  = "westeurope"
vnet_resource_group_name  = "prod-networks-rg"
hub_vnet_name             = "hub1-firewalvnet"
kube_vnet_name            = "prod-kubevnet"
kube_resource_group_name  = "prod-kubernetes-rg"
nodepool_nodes_count      = 4
nodepool_vm_size          = "Standard_D2_v2"
min_node_count            = 2
max_node_count            = 10
node_auto_scaling_enabled = true
dedicated_np_count_min    = 1
dedicated_np_count_max    = 1



##### VPN CONNECTION ####
vpn_gateway_address            = "203.0.113.1" # on-premises VPN device's public IP
vpn_local_onprem_address_space = ["192.168.1.0/24"]
vpn_preshared_key              = ""



####### BASTION #######
bastion_vm_size              = "Standard_B2s"
bastion_storage_account_type = "StandardSSD_LRS"


##Subnets
### hub vpc ###
hub_address_space             = ["100.23.0.0/21"]
hub_address_space_string      = "100.23.0.0/21"
jumpbox-subnet                = ["100.23.0.0/24"]
AzureFirewallSubnet           = ["100.23.1.0/24"]
api-gw-subnet                 = ["100.23.2.0/24"]
AzureFirewallManagementSubnet = ["100.23.5.0/24"]
apigateway_private_ip_address = "100.23.2.9"

### Kubernetes cluster Vpc ###
kube_address_space        = ["110.10.0.0/21"]
kube_address_space_string = "110.10.0.0/21"
aks-subnet                = ["110.10.2.0/23"]
vpn_subnet_address_space  = ["110.10.6.0/23"]

apigateway_sku             = "Standard_v2"
apigateway_tier            = "Standard_v2"
apigateway_capacity        = 2
pod_cidr                   = "192.168.0.0/16"
aks_cluster_sku_tier       = "Standard"
network_docker_bridge_cidr = "172.16.0.1/16"
network_dns_service_ip     = "10.0.0.10"
network_service_cidr       = "10.0.0.0/24"
node_pool_name             = "prodnodes"
dedicated_node_pool_name   = "proddedicated"
firewall_sku_name          = "AZFW_VNet"
firewall_sku_tier          = "Basic"
env                        = "production"
kube_version_prefix        = "1.31"
##DATABASE ##
pg_server_name = "zaho-prod-db"


### PUBLIC DOMAIN NAMES ##
domain_names = [
  "test.ng"
]


zone_test_record_names = []





#### Private Storage Accounts ####
private_storage_account_name = "testprodbuckets"
private_containers = [
  "media",
  "accounting-finance",

]



#### Public Storage Accounts ####
public_storage_account_name = "testbuckets"
public_containers = [
  "media",
  "documents",
  "logs"
]
