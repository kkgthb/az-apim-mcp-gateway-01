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
      }
    }
  }
  response_export_values    = ["properties"]
  schema_validation_enabled = false
}
