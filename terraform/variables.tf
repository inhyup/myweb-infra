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