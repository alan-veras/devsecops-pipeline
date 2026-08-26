variable "project" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "region" {
  description = "AWS region for ECR login and service endpoints"
  type        = string
}

variable "ami_id" {
  description = "AL2023 ARM64 AMI id; resolved via SSM public parameter in Fase 3"
  type        = string
}

variable "instance_type" {
  description = "Instance type sized for free tier"
  type        = string
  default     = "t4g.micro"
}

variable "security_group_id" {
  description = "SG id from the network module"
  type        = string
}

variable "ecr_repo" {
  description = "ECR repository URL for docker login (no tag)"
  type        = string
}

variable "ecr_repo_arn" {
  description = "ECR repository ARN scoping pull permissions"
  type        = string
}

variable "ecr_image" {
  description = "Full immutable image reference repo:tag to run"
  type        = string
}
