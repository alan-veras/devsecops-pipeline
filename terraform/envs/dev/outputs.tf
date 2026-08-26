output "repository_url" {
  value       = module.registry.repository_url
  description = "ECR repository URL for image push"
}

output "repository_arn" {
  value       = module.registry.repository_arn
  description = "ECR repository ARN"
}

output "security_group_id" {
  value       = module.network.security_group_id
  description = "App security group id"
}

output "subnet_ids" {
  value       = module.network.subnet_ids
  description = "Public subnet ids for the EC2 instance"
}
