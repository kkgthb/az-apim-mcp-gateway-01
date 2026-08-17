data "azurerm_client_config" "current_azurerm_config" {
  lifecycle {
    postcondition {
      condition     = (coalesce(self.client_id, "") == "04b07795-8ddb-461a-bbee-02f9e1bf7b46")
      error_message = "AzureRM login state client ID, in submodule, is not the well-known Azure CLI GUID."
    }
    postcondition {
      condition     = (coalesce(self.object_id, "") != "")
      error_message = "AzureRM login state, in submodule, does not bear a logged-in user object ID."
    }
  }
}

resource "random_string" "my_apim_generated_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_api_management" "my_apim" {
  name                = "apim${random_string.my_apim_generated_name.result}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  publisher_name      = "Demo Publisher"
  publisher_email     = "admin@example.com"
  # MCP Servers in APIM require Developer/Basic/Basic v2/Standard/Standard v2/Premium/Premium v2.
  # The Consumption tier does not support MCP servers, so Basic v2 is used here (cheapest supported tier).
  sku_name = "BasicV2_1"
}
