resource "azurerm_container_registry" "acr" {
  name                = "${var.demoRegistryPrefix}registry"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Standard"
  admin_enabled       = true
  anonymous_pull_enabled = true

  tags = {
    environment = "${var.environment}"
  }
}
