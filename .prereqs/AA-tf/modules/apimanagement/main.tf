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
