variable "ai_gateway" {
  description = "The parent AI Gateway resource."
  type = object({
    id = string
  })
  nullable = false
}