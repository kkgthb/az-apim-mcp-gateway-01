# Registers an external MCP server (Microsoft Learn) as an "mcp"-typed API in APIM. This is
# the resource behind the "MCP Servers" blade in the portal. The azurerm provider does not yet
# support apiType = "mcp" or its child "tools" resource, so azapi is used instead (per the
# 2025-09-01-preview Microsoft.ApiManagement/service/apis[/tools] schema).
resource "azapi_resource" "mslearn_mcp_api" {
  type      = "Microsoft.ApiManagement/service/apis@2025-09-01-preview"
  name      = "${var.workload_nickname}-mslearn-mcp"
  parent_id = var.apim_instance.id
  body = {
    properties = {
      displayName          = "Microsoft Learn MCP (gated)"
      description          = "Gated proxy of the public Microsoft Learn MCP server. Only an allow-listed subset of its tools is exposed."
      path                 = "mslearn-mcp"
      protocols            = ["https"]
      type                 = "mcp"
      apiType              = "mcp"
      serviceUrl           = "https://learn.microsoft.com/api/mcp"
      subscriptionRequired = false
      mcpProperties = {
        transportType = "streamable" # Valid options are "sse" and "streamable"
        endpoints = {
          message = { uriTemplate = "/mcp" }
        }
      }
    }
  }
  response_export_values    = ["properties"]
  schema_validation_enabled = false
}

# Option A (static allowlist) policy: intercepts tools/list and tools/call at the JSON-RPC
# level, since APIM cannot discover/manage this external MCP server's tools any other way
# (confirmed in the portal's Tools blade for this API: "Tools are not visible for external MCP
# servers"). See allowlist-policy.xml for details.
resource "azapi_resource" "mslearn_mcp_api_policy" {
  type      = "Microsoft.ApiManagement/service/apis/policies@2025-09-01-preview"
  name      = "policy"
  parent_id = azapi_resource.mslearn_mcp_api.id

  body = {
    properties = {
      format = "rawxml"
      value  = file("${path.module}/allowlist-policy.xml")
    }
  }

  schema_validation_enabled = false
}
