locals {
  allowed_tools = [
    "microsoft_docs_search",
    "microsoft_docs_fetch",
  ]
  blocked_tools = [
    "microsoft_code_sample_search",
  ]
}

resource "azapi_resource" "mslearn_mcp_tool_server" {
  type      = "Microsoft.ApiManagement/aigateways/workspaces/toolServers@2026-09-01-preview"
  name      = "mslearn-tools"
  parent_id = "${var.ai_gateway.id}/workspaces/default"
  body = {
    properties = {
      name                 = "Microsoft Learn MCP (gated)"
      description          = "Gated proxy of the public Microsoft Learn MCP server. Only an allow-listed subset of its tools is exposed."
      type                 = "mcp"
      allowList            = local.allowed_tools
      blocked              = local.blocked_tools
      subscriptionRequired = false
      endpoints = [
        {
          id   = "microsoft-learn"
          kind = "mcp"
          mcp = {
            url       = "https://learn.microsoft.com/api/mcp"
            transport = "streamableHttp"
          }
          required = true
        }
      ]
    }
  }
  response_export_values    = ["*"]
  schema_validation_enabled = false
}
