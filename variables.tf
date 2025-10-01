variable "vnet_resource_group_name" {
  description = "The resource group name to be created"
  default     = "networks"
}

variable "hub_vnet_name" {
  description = "Hub VNET name"
  default     = "hub1-firewalvnet"
}

variable "kube_vnet_name" {
  description = "AKS VNET name"
  default     = "spoke1-kubevnet"
}

variable "kube_version_prefix" {
  description = "AKS Kubernetes version prefix. Formatted '[Major].[Minor]' like '1.18'. Patch version part (as in '[Major].[Minor].[Patch]') will be set to latest automatically."
  default     = "1.31"
}

variable "kube_resource_group_name" {
  description = "The resource group name to be created"
  default     = "nopublicipaks"
}

variable "nodepool_nodes_count" {
  description = "Default nodepool nodes count"
  default     = 1
}

variable "nodepool_vm_size" {
  description = "Default nodepool VM size"
  default     = "Standard_D2_v2"
}

variable "network_docker_bridge_cidr" {
  description = "CNI Docker bridge cidr"
  default     = "172.16.0.1/16"
}

variable "network_dns_service_ip" {
  description = "CNI DNS service IP"
  default     = "10.2.0.10"
}

variable "network_service_cidr" {
  description = "CNI service cidr"
  default     = "10.2.0.0/24"
}

variable "node_pool_name" {

}

variable "node_auto_scaling_enabled" {
  default = false
}

variable "firewall_sku_name" {

}

variable "firewall_sku_tier" {

}

variable "env" {

}

variable "aks_cluster_sku_tier" {

}


variable "hub_address_space" {
  description = "The address space for the virtual network in CIDR notation"
  type        = list(string)
}

variable "hub_address_space_string" {
  type = string
}


variable "kube_address_space" {
  description = "The address space for the virtual network in CIDR notation"
  type        = list(string)
}


variable "kube_address_space_string" {
  description = "The address space for the virtual network in CIDR notation"
  type        = string
}



variable "jumpbox-subnet" {
  description = "The address space for the virtual network in CIDR notation"
  type        = list(string)
}

variable "AzureFirewallSubnet" {
  description = "The address space for the virtual network in CIDR notation"
  type        = list(string)
}


variable "aks-subnet" {
  description = "The address space for the virtual network in CIDR notation"
  type        = list(string)
}



variable "min_node_count" {

}
variable "max_node_count" {

}




variable "pg_server_name" {

}

variable "location" {

}

variable "domain_names" {

}

variable "api-gw-subnet" {

}

variable "apigateway_sku" {

}

variable "apigateway_tier" {

}

variable "apigateway_capacity" {

}

variable "zone_zaho_record_names" {

}
variable "AzureFirewallManagementSubnet" {

}


variable "bastion_vm_size" {

}


variable "bastion_storage_account_type" {

}




variable "private_storage_account_name" {
  description = "Name of the storage account"
  type        = string
}



variable "public_storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "containers" {
  description = "List of container names to create"
  type        = list(string)
  default     = []
}


variable "private_containers" {

}


variable "dedicated_np_count_min" {

}


variable "dedicated_np_count_max" {

}

variable "dedicated_node_pool_name" {

}

variable "apigateway_private_ip_address" {
  default = null
  type    = string
}

variable "vpn_subnet_address_space" {
  default = null

}


variable "vpn_preshared_key" {
  type    = string
  default = null
}

variable "vpn_gateway_address" {
  default = null
  type    = string
}

variable "vpn_local_onprem_address_space" {
  default = null

}


variable "source_port_range" {
  description = "The source port range for the NSG rule"
  type        = string
  default     = "*" # Default to allow all source ports
}

variable "destination_port_range" {
  description = "The destination port range for the NSG rule"
  type        = string
  default     = "80" # Default to allow HTTP traffic
}

variable "source_address_prefix" {
  description = "The source address prefix for the NSG rule"
  type        = string
  default     = "*" # Default to allow traffic from any source
}

variable "destination_address_prefix" {
  description = "The destination address prefix for the NSG rule"
  type        = string
  default     = "*" # Default to allow traffic to any destination
}




# variable "pod_cidr" {

# }
# variable "domain_names" {

# }

# variable "cloudflare_zone_id" {

# }
