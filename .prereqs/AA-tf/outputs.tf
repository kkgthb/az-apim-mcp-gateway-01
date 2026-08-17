output "resource_group_name" {
  value = azurerm_resource_group.my_resource_group.name
}

output "apim_name" {
  value = module.apimanagement.apim_instance.name
}