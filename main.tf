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
  features {}
  
  subscription_id   = "e1fec9f3-3d89-4113-8eaf-d8915babcf59"
  tenant_id         = "c894abff-2699-4efc-a196-8e1565ec8b93"
  client_id         = "cfb23b33-17f6-475c-b1b0-f3cfaeb5446a"
  use_oidc          = true
  #client_secret     = "${var.terraform_secret}"
}

resource "azurerm_resource_group" "default" {
  name     = "${var.demoPrefix}-rg"
  location = "East US"

  tags = {
    environment = "${var.environment}"
  }
}