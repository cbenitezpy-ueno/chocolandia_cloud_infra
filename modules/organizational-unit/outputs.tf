output "id" {
  description = "Organizational unit ID"
  value       = aws_organizations_organizational_unit.this.id
}

output "arn" {
  description = "Organizational unit ARN"
  value       = aws_organizations_organizational_unit.this.arn
}