data "azurerm_client_config" "current_azurerm_config" {
  provider = azurerm.demo
  lifecycle {
    postcondition {
      condition     = (coalesce(self.client_id, "") == "04b07795-8ddb-461a-bbee-02f9e1bf7b46")
      error_message = "AzureRM login state client ID is not the well-known Azure CLI GUID."
    }
    postcondition {
      condition     = (coalesce(self.subscription_id, "") == var.az_sub_id)
      error_message = "AzureRM login state subscription ID is not as passed in."
    }
    postcondition {
      condition     = (coalesce(self.object_id, "") != "")
      error_message = "AzureRM login state does not bear a logged-in user object ID."
    }
  }
}

data "azapi_client_config" "current_azapi_config" {
  provider = azapi.demo
  lifecycle {
    postcondition {
      condition     = (coalesce(self.subscription_id, "") == var.az_sub_id)
      error_message = "AzAPI login state subscription ID is not as passed in."
    }
    postcondition {
      condition     = (coalesce(self.object_id, "") != "")
      error_message = "AzAPI login state does not bear a logged-in user object ID."
    }
  }
}

resource "azurerm_resource_group" "my_resource_group" {
  provider = azurerm.demo
  name     = "${var.workload_nickname}-rg-demo"
  location = "centralus"
}

module "apimanagement" {
  source = "./modules/apimanagement"
  providers = {
    azurerm = azurerm.demo
  }
  resource_group = {
    id       = azurerm_resource_group.my_resource_group.id
    name     = azurerm_resource_group.my_resource_group.name
    location = azurerm_resource_group.my_resource_group.location
  }
  workload_nickname = var.workload_nickname
}
