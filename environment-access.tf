resource "azuread_group" "environment_owners" {
  display_name     = "demo-environment-owners-${var.environment}"
  owners           = ["4dab6b68-9d1f-414f-8ede-5f7acd5e9fb0",
                      "5c102dd0-6f07-475e-9ab9-b58034e46631"]
  security_enabled = true

}

# resource "azuread_conditional_access_policy" "example" {
#   display_name = "example policy"
#     devices {
#       filter {
#         rule = "device.state eq \"Compliant\""
#       }
#     }
#     groups {
#       included_groups = [environment_owners.object_id]
#     }
# }

# Set up workforce identity federation or user provisioning from Azure AD to GCP
# resource "google_workforce_identity_pool" {}
# resource "google_workforce_identity_provider" {}

resource "azurerm_role_assignment" "owners_to_resource_group" {
  principal_id                     = azuread_group.environment_owners.object_id
  role_definition_name             = "Contributor"
  scope                            = azurerm_resource_group.default.id
}

resource "google_project_iam_member" "owners_to_project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "group:hashiConfDemoOpsTeam@hashiconf-entra-demo.app"  ##Note: This needs to be replaced to reference the display name of the group created in AAD
}
