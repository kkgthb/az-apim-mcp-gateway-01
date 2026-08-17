# Configure the AzAPI provider (used for Azure resources/preview features not yet
# supported by azurerm, e.g. the MCP server "apis" and "apis/tools" resource types).
provider "azapi" {
  alias           = "demo"
  tenant_id       = var.entra_tenant_id
  subscription_id = var.az_sub_id
}

# Configure the AzureRM provider
provider "azurerm" {
  features {}
  alias                           = "demo"
  tenant_id                       = var.entra_tenant_id
  subscription_id                 = var.az_sub_id
  resource_provider_registrations = "none"
}