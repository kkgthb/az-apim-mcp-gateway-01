output "api_management_service_name" {
  value = azurerm_api_management.my_apim.name
}

output "apim_instance" {
  description = "Key details for the APIM instance"
  value = {
    id   = azurerm_api_management.my_apim.id
    name = azurerm_api_management.my_apim.name
    management_api_url = azurerm_api_management.my_apim.management_api_url
  }
}
