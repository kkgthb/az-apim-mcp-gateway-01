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
  location = "eastus2"
}

module "ai_gateway" {
  source = "./modules/shared_ai_gateway"
  providers = {
    azapi  = azapi.demo
    random = random
  }
  resource_group = azurerm_resource_group.my_resource_group
}

module "mcplimiterdemo" {
  source = "./modules/mcp_limiter_demo"
  providers = {
    azapi = azapi.demo
  }
  ai_gateway = module.ai_gateway.ai_gateway
}
