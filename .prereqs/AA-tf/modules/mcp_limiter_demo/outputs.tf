output "tool_server_name" {
  value = azapi_resource.mslearn_mcp_tool_server.name
}

output "gateway_url" {
  value = azapi_resource.mslearn_mcp_tool_server.output.properties.gatewayEndpoints[0].url
}

output "allowed_tools" {
  value = local.allowed_tools
}