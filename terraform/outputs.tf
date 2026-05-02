output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "secuirty_group_id" {
  description = "ID of the security group for web servers"
  value       = aws_security_group.web_sg.id
}

