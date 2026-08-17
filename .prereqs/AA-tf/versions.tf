terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=2.12.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.9.0"
    }
  }
}
