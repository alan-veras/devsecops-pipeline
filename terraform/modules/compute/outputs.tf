output "launch_template_id" {
  value = aws_launch_template.app.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}
