

variable "zone_name" {
  description = "The name of the DNS zone."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "target_resource_id" {
  description = "The resource ID of the target resource."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the DNS records."
  type        = map(string)
  default     = {}
}

variable "zone_emple_record_names" {

}