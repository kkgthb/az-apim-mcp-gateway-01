# The backend for the passthrough MCP server. The portal wizard ("Expose an existing MCP
# server") creates this as a separate backend resource rather than using the API's serviceUrl
# field directly - serviceUrl looked accepted by the ARM API (no validation error) but silently
# produced a broken passthrough (tools/list returned an empty array and tools/call 500'd
# internally, confirmed via APIM request tracing). Using a real backend resource + backendId,
# matching what the portal wizard actually does, is required for passthrough forwarding to work.
resource "azapi_resource" "mslearn_mcp_backend" {
  type      = "Microsoft.ApiManagement/service/backends@2025-09-01-preview"
  name      = "${var.workload_nickname}-mslearn-mcp-backend"
  parent_id = var.apim_instance.id
  body = {
    properties = {
      protocol = "http" # Confusingly, this just means "HTTP-family", not that TLS is disabled - the url below is https.
      url      = "https://learn.microsoft.com"
    }
  }
  schema_validation_enabled = false
}

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
      backendId            = azapi_resource.mslearn_mcp_backend.name
      subscriptionRequired = false
      mcpProperties = {
        transportType = "streamable" # Valid options are "sse" and "streamable"
        endpoints = {
          message = { uriTemplate = "/api/mcp" }
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
