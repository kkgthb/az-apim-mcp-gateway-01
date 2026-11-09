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
          credentials = {
            # 2026-09-01-preview undocumentedly can manage toolServers as of 11/6/2026, 
            # but trying to pass in "credentials" is a step too far for it, 
            # and version 2026-11-01 seems to not actually exist in real life _(`400` `Bad Request` `MissingOrIncorrectVersionParameter`)_, 
            # so I guess all that remains to be done is wait for Microsoft to fix things, 
            # update the `type` here & in the parent resource, 
            # and try again.
            # 2026-11-01 and various Foundry docs I've seen about integrating with these things 
            # definitely seem to imply that it should be possible to specify that the MS Learn MCP server doesn't require auth.
            # https://github.com/Azure/azure-rest-api-specs/blob/180f62a563934f8c0fdd37e0b42845bc110340d3/specification/apimanagement/resource-manager/Microsoft.ApiManagement/AIGateway/AIGatewayToolServer.tsp#L251
            # https://github.com/Azure/azure-rest-api-specs/blob/180f62a563934f8c0fdd37e0b42845bc110340d3/specification/apimanagement/resource-manager/Microsoft.ApiManagement/AIGateway/stable/2026-11-01/openapi.json#L6305
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
