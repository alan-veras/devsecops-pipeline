variable "project" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "region" {
  description = "AWS region, also drives AZ suffix naming (a/b)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr" {
  description = "CIDR block of public subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr" {
  description = "CIDR block of public subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_cidr" {
  description = "Operator CIDR (single IP /32) allowed to SSH - never 0.0.0.0/0"
  type        = string
}
