variable "workload_nickname" {
  type     = string
  nullable = false
}

variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    name     = string
    location = string
  })
  nullable = false
}

variable "apim_instance" {
  description = "Key details of the parent APIM instance to attach the MCP server to."
  type = object({
    id                 = string
    name               = string
    management_api_url = string
  })
  nullable = false
}
