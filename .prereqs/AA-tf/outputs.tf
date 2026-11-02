output "resource_group_name" {
  value = azurerm_resource_group.my_resource_group.name
}

output "ai_gateway_name" {
  value = module.ai_gateway.ai_gateway.name
}

output "mcp_server_gateway_url" {
  description = "Assigned runtime URL of the gated Microsoft Learn MCP tool server."
  value       = module.mcplimiterdemo.gateway_url
}

output "mcp_allowed_tools" {
  description = "The tools exposed through the AI Gateway tool server."
  value       = module.mcplimiterdemo.allowed_tools
}