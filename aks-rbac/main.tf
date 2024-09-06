# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

# Create a resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Create a subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

# Create an additional node pool
resource "azurerm_kubernetes_cluster_node_pool" "user_node_pool" {
  name                  = "usernodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS3_v2"
  node_count            = 2

  tags = {
    Environment = "Production"
  }
}

# Configure RBAC
resource "azurerm_role_assignment" "aks_rbac" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "Network Contributor"
  scope                            = azurerm_virtual_network.aks_vnet.id
  skip_service_principal_aad_check = true
}

# Output the cluster's kube_config
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}