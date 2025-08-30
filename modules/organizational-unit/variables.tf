variable "name" {
  description = "Name of the organizational unit"
  type        = string
}

variable "parent_id" {
  description = "Parent organizational unit or root ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the organizational unit"
  type        = map(string)
  default     = {}
}