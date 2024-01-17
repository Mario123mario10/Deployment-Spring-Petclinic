variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 1
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
}


variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8-dns"
}

variable "cluster_name" {
  default = "k8-petclinic"
}


variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "petclinic-k8s"
}


variable "log_analytics_workspace_location" {
  default = "eastus"
}

variable log_analytics_workspace_name {
    default = "Petclinic-LogAnalyticsWorkspace"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}
