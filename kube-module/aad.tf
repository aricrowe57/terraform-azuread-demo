# Create managed identities, service principals, machine identities in Azure AD
# resource "azuread_service_principal" "service-principal" {}

# Set up workload identity federation in Google Cloud
# resource "google_workload_identity_pool" {}
# resource "google_workload_identity_provider" {}
# resource "google_iam_policy_binding" {}

# Set up workload identity federation from Kubernetes cluster to Azure AD
# resource "azuread_application_federated_identity_credential" "fic" {
#  application_object_id = azuread_application.app-registration.object_id
#  display_name          = "kube-fic"
#  description           = "FIC for Kubernetes on GKE"
#  audiences             = ["api://AzureADTokenExchange"]
#  issuer                = "https://container.googleapis.com/v1/projects/hashiconf-demo-364100/locations/us-west1/clusters/hashiconf-demo-364100-gke"
#  subject               = "system:serviceaccount:sa-namspace:kube-service-account"
#}

# Create Azure RBAC role assignment to access resources in Azure
# resource "azurerm_role_assignment" "access_to_datastore" {
#   principal_id                     = service_principal.object_id
#   role_definition_name             = "Blob storage data reader"
#   scope                            = azurerm_resource_group.default.id
# }

# Create permission grants to Microsoft Graph
# resource "azuread_app_role_assignment" "graph_permissions" {}

resource "azuread_application" "app-registration" {
  display_name     = "Hashiconf Entra Demo"
  web {
     redirect_uris = ["http://34.149.210.42/login", "https://terraform-entra-demo.app/login"]
  }
  sign_in_audience = "AzureADMultipleOrgs"

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
			type =  "Scope"
		}

    resource_access {
      id   = "a154be20-db9c-4678-8ab7-66f6cc099a59"
			type =  "Scope"
		}
  }

  app_role {
    allowed_member_types = ["Application", "User"]
    description          = "Developers of this application"
    display_name         = "Developers"
    enabled              = true
    value                = "Developers.All"
    id                   = "39915761-d5e8-494f-bfaf-6e78fd8a1982"
  }
}

resource "azuread_service_principal" "service-principal" {
  application_id = azuread_application.app-registration.application_id
  use_existing = true
  app_role_assignment_required = true
}

resource "azuread_app_role_assignment" "example" {
  app_role_id         = azuread_service_principal.service-principal.app_role_ids["Developers.All"]
  principal_object_id = data.terraform_remote_state.state.outputs.group_object_id
  resource_object_id  = azuread_service_principal.service-principal.object_id
}





















resource "azuread_application_password" "client-secret" {
  application_object_id = azuread_application.app-registration.object_id

}


