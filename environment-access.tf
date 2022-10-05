resource "azuread_group" "environment_owners" {
  display_name     = "demo-environment-owners-${var.environment}"
  owners           = ["4dab6b68-9d1f-414f-8ede-5f7acd5e9fb0",
                      "5c102dd0-6f07-475e-9ab9-b58034e46631"]
  security_enabled = true

  #members = [
    #"4dab6b68-9d1f-414f-8ede-5f7acd5e9fb0",
    #"5c102dd0-6f07-475e-9ab9-b58034e46631",
    #"f94cd823-e26f-422c-abaa-a4259a677acd"
  #]
}

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




# Have to figure out why I keep getting access errors
#resource "azuread_conditional_access_policy" "require-mfa-for-owners" {
#  display_name = "Require MFA for environment owners"
#  state        = "enabled"
#  conditions {
#    client_app_types    = ["all"]
#    applications {
#      included_applications = ["All"]
#    }
#    devices {
#      filter {
#        mode = "exclude"
#        rule = "device.operatingSystem eq \"Doors\""
#      }
#    }
#    locations {
#      included_locations = ["All"]
#    }
#    platforms {
#      included_platforms = ["all"]
#    }
#    users {
#      included_groups = [azuread_group.environment_owners.object_id]
#    }
#  }
#  grant_controls {
#    operator          = "OR"
#    built_in_controls = ["mfa"]
#  }
#}