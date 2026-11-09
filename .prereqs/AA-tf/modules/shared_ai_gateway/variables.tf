variable "resource_group" {
  description = "Parent resource group parameters."
  type = object({
    id       = string
    name     = string
    location = string
  })
  nullable = false
}