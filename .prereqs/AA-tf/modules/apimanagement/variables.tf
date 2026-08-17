variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    name     = string
    location = string
  })
  nullable = false
}

variable "workload_nickname" {
  type = string
  nullable = false
}
