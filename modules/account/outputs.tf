output "id" {
  description = "AWS account ID"
  value       = aws_organizations_account.this.id
}

output "arn" {
  description = "AWS account ARN"
  value       = aws_organizations_account.this.arn
}

output "email" {
  description = "AWS account email"
  value       = aws_organizations_account.this.email
}

output "status" {
  description = "AWS account status"
  value       = aws_organizations_account.this.status
}