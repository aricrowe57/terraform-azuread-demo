provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.demoPrefix}-rg"
  location = "East US"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.demoPrefix}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.demoPrefix}-k8s"

  identity {
    type = "SystemAssigned"
  }
  
  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
  
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.demoRegistryPrefix}registry"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_role_assignment" "cluster_to_registry" {
  principal_id                     =  azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  #scope                           = "/subscriptions/e1fec9f3-3d89-4113-8eaf-d8915babcf59/resourceGroups/arcroweHashicorpDemo/providers/Microsoft.ContainerRegistry/registries/arcroweRegistry"
  skip_service_principal_aad_check = true
}

resource "null_resource" "docker_build" {
  provisioner "local-exec" {
  command = "docker build azure-vote -t ${azurerm_container_registry.acr.login_server}/azure-vote-front:latest"
  }
}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
  command = "az acr login --name ${azurerm_container_registry.acr.login_server}"
  }
  depends_on = [
    null_resource.docker_build
  ]
}

resource "null_resource" "push" {
  provisioner "local-exec" {
  command = "docker push ${azurerm_container_registry.acr.login_server}/azure-vote-front:latest"
  }
  depends_on = [
    null_resource.docker_login
  ]
}
