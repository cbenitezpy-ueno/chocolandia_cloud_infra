variable "name" {
  description = "Name of the AWS account"
  type        = string
}

variable "email" {
  description = "Email address for the AWS account"
  type        = string
}

variable "parent_id" {
  description = "Parent organizational unit ID"
  type        = string
}

variable "close_on_deletion" {
  description = "Whether to close the account on deletion"
  type        = bool
  default     = false
}

variable "create_govcloud" {
  description = "Whether to create a corresponding GovCloud account"
  type        = bool
  default     = false
}

variable "iam_user_access_to_billing" {
  description = "Whether to allow IAM users access to billing"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.iam_user_access_to_billing)
    error_message = "iam_user_access_to_billing must be either ALLOW or DENY."
  }
}

variable "tags" {
  description = "Tags to apply to the account"
  type        = map(string)
  default     = {}
}