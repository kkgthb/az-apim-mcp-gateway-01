terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=2.13.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.9.1"
    }
  }
}
