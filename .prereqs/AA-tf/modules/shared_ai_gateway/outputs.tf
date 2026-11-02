output "ai_gateway" {
  description = "AI Gateway resource details used by the MCP tool-server module."
  value = {
    id               = azapi_resource.ai_gateway.id
    name             = azapi_resource.ai_gateway.name
    default_hostname = azapi_resource.ai_gateway.output.properties.frontend.defaultHostname
  }
}