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
            # by attaching an `https://azure-api.net/aigateway/Data.All`-delegated-scoped, 
            # `https://azure-api.net/aigateway`-audienced, 
            # appropriately-Azure-RBAC-role'd token.
            # I think this is stupid because it means letting a potentially-leaky MCP client/harness 
            # handle a JWT token that was completely unnecessary to get the work done 
            # and now could potentially be leaked and used in replay attacks, credential harvesting infections, etc.
            # I think it's dumb that `Microsoft.ApiManagement/aigateways` 100% enforces ingress authentication into itself; blegh.
            # Also, if we were, say, protecting an Outlook MCP server or something, 
            # then this would, I believe, be where we set up the gateway to be able to use OAuth to do 
            # delegated/on-behalf-of work for whoever is ultimately trying to get through to the Outlook MCP server.
            # This would, I believe, be part of setting up the gateway to be able to 
            # obtain an Outlook-scoped token on behalf of (OBO) whichever identity principal passed 
            # an `https://azure-api.net/aigateway/Data.All`-delegated-scoped token into the gateway.
            # I think.  That, or such a flow is simply impossible with `Microsoft.ApiManagement/aigateways` 
            # and a `Microsoft.ApiManagement/aigateways` resource can only talk to a backend as itself under its own permissions.
            # Which seems weird and to halfway defeat the point of "protecting" MCP servers, 
            # so I must be misreading things.
            # LLM says:  "`credentials` configures the gateway's outbound authentication to the backend.
            # "The documented backend OAuth connection flow does not establish per-caller
            # "on-behalf-of token exchange. Don't assume the gateway forwards or exchanges
            # each caller's identity for a backend token."
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
