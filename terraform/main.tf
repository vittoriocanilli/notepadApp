resource "azurerm_resource_group" "notepadResources" {
  name     = "notepad-resources"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "notepadCluster" {
  name                = "notepad-cluster"
  location            = azurerm_resource_group.notepadResources.location
  resource_group_name = azurerm_resource_group.notepadResources.name
  dns_prefix          = "notepad-cluster"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.notepadCluster.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.notepadCluster.kube_config_raw
}