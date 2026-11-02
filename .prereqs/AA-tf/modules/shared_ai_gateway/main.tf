resource "random_string" "ai_gateway_name_suffix" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azapi_resource" "ai_gateway" {
  type      = "Microsoft.ApiManagement/aigateways@2026-09-01-preview"
  name      = "aigw${random_string.ai_gateway_name_suffix.result}"
  parent_id = var.resource_group.id
  location  = var.resource_group.location
  identity {
    type = "SystemAssigned"
  }
  body = {
    properties = {}
    sku = {
      name = "Premium" # TODO:  downgrade once the free ride is over!
    }
  }
  response_export_values    = ["*"]
  schema_validation_enabled = false
}
