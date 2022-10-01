terraform {
   required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.7.0"
    }
    google = {
      source = "hashicorp/google"
      version = "3.61.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "terraform-infrastructure"
        storage_account_name = "arcroweterraformstate"
        container_name       = "tfstate"
        key                  = "localkube.terraform.tfstate"
        subscription_id      = "e1fec9f3-3d89-4113-8eaf-d8915babcf59"
        tenant_id            = "c894abff-2699-4efc-a196-8e1565ec8b93"
        client_id            = "cfb23b33-17f6-475c-b1b0-f3cfaeb5446a"
        #use_oidc             = true
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

provider "google" {
  project = "hashiconf-demo-364100"
  region  = "us-west1"
  zone    = "us-west1-a"
}
