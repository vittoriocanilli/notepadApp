variable TENANT_ID {}
variable SUBSCRIPTION_ID {}
variable TF_SPA_ID {}
variable TF_SPA_SECRET {}

provider "azurerm" {
  version = "=2.33.0"

  subscription_id = var.SUBSCRIPTION_ID
  client_id = var.TF_SPA_ID
  client_secret = var.TF_SPA_SECRET
  tenant_id = var.TENANT_ID

  features {}
}

terraform {
  required_version = "= 0.12.26"
}

resource "azurerm_kubernetes_cluster" "notepadCluster" {
  name                = "notepad-cluster"
  location            = var.azure_region
  resource_group_name = var.resource_group
  dns_prefix          = "notepad-cluster"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.notepadCluster.kube_config_raw
}