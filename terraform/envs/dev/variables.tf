variable "project" {
  description = "Project name used as resource prefix"
  type        = string
  default     = "devsecops-pipeline"
}

variable "region" {
  description = "AWS region - fixed at us-east-1 for free tier eligibility"
  type        = string
  default     = "us-east-1"
}

variable "admin_cidr" {
  description = "Operator IP in CIDR form (e.g. 203.0.113.10/32) allowed to SSH"
  type        = string
}

variable "image_tag" {
  description = "Immutable image tag to deploy (git sha in CI; never :latest)"
  type        = string
  default     = "manual"
}

variable "ami_id" {
  description = "AL2023 ARM64 AMI id for the launch template"
  type        = string
}
