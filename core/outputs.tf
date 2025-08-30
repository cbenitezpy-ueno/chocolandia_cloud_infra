output "core_ou_id" {
  description = "Core Organizational Unit ID"
  value       = aws_organizations_organizational_unit.core.id
}

output "security_account_id" {
  description = "Security Account ID"
  value       = aws_organizations_account.security.id
}

output "logging_account_id" {
  description = "Logging Account ID"
  value       = aws_organizations_account.logging.id
}

output "shared_services_account_id" {
  description = "Shared Services Account ID"
  value       = aws_organizations_account.shared_services.id
}