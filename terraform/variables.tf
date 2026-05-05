variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "myweb"
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = "inhyup"
}

variable "github_repo" {
  description = "GitHub repo name"
  type        = string
  default     = "myweb-infra"
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
  default     = "Z3D6Y3KC61Y1GI"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "950888816014"
}