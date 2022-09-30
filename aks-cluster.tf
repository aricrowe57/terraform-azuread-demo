terraform {
   required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.7.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "terraform-infrastructure"
        storage_account_name = "arcroweterraformstate"
        container_name       = "tfstate"
        key                  = "local.terraform.tfstate"
        subscription_id      = "e1fec9f3-3d89-4113-8eaf-d8915babcf59"
        tenant_id            = "c894abff-2699-4efc-a196-8e1565ec8b93"
        client_id            = "cfb23b33-17f6-475c-b1b0-f3cfaeb5446a"
        use_oidc             = true
    }

}


provider "azurerm" {
  subscription_id   = "e1fec9f3-3d89-4113-8eaf-d8915babcf59"
  tenant_id         = "c894abff-2699-4efc-a196-8e1565ec8b93"
  client_id         = "cfb23b33-17f6-475c-b1b0-f3cfaeb5446a"
  use_oidc          = true
  #client_secret     = "${var.terraform_secret}"

  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.demoPrefix}-rg"
  location = "East US"

  tags = {
    environment = "${var.environment}"
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

  #role_based_access_control {
  #  enabled = true
  #}

  tags = {
    environment = "${var.environment}"
  }
  
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.demoRegistryPrefix}registry"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_role_assignment" "cluster_to_registry" {
  principal_id                     =  azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

#resource "null_resource" "docker_build" {
#  provisioner "local-exec" {
#  command = "docker build app -t ${azurerm_container_registry.acr.login_server}/helloapp:latest"
#  }
#}

#resource "null_resource" "docker_login" {
#  provisioner "local-exec" {
#  command = "az acr login --name ${azurerm_container_registry.acr.login_server}"
#  }
#  depends_on = [
#    null_resource.docker_build
#  ]
#}

#resource "null_resource" "push" {
#  provisioner "local-exec" {
#  command = "docker push ${azurerm_container_registry.acr.login_server}/helloapp:latest"
#  }
#  depends_on = [
#    null_resource.docker_login
#  ]
#}

resource "azuread_group" "environment_owners" {
  display_name     = "demo-environment-owners-${var.environment}"
  owners           = ["4dab6b68-9d1f-414f-8ede-5f7acd5e9fb0",
                      "5c102dd0-6f07-475e-9ab9-b58034e46631"]
  security_enabled = true

  members = [
    "4dab6b68-9d1f-414f-8ede-5f7acd5e9fb0",
    "5c102dd0-6f07-475e-9ab9-b58034e46631",
    "f94cd823-e26f-422c-abaa-a4259a677acd"
  ]
}

resource "azurerm_role_assignment" "owners_to_resource_group" {
  principal_id                     = azuread_group.environment_owners.object_id
  role_definition_name             = "Contributor"
  scope                            = azurerm_resource_group.default.id
}
