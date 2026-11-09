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
  type      = "Microsoft.ApiManagement/aigateways/workspaces/toolServers@2025-09-01-preview"
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
          credentials = {
            # Frustrating.  Per LLM, `credentials` only configures the gateway's 
            # outbound authentication to the MS Learn MCP backend, 
            # but doesn't impact requirements for the calling MCP client to authenticate into the gateway 
            # when POSTing to https://BLAHBLAHBLAH.ai.gateway.azure.com/default/toolservers/mslearn-tools/mcp 
            # by attaching an `https://ai.azure.com/Data.All`-scoped Entra ID token.
            # I think this is stupid because it means letting a potentially-leaky MCP client/harness 
            # handle a JWT token that was completely unnecessary to get the work done 
            # and now could potentially be leaked and used in replay attacks, credential harvesting infections, etc.
            # I think it's dumb that `Microsoft.ApiManagement/aigateways` 100% enforces ingress authentication into itself; blegh.
            type = "none"
          }
          required = true
        }
      ]
    }
  }
  response_export_values    = ["*"]
  schema_validation_enabled = false
}
