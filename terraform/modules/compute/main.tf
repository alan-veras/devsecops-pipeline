data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_pull" {
  name               = "${var.project}-ec2-pull"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = { Name = "${var.project}-ec2-pull-role" }
}

resource "aws_iam_role_policy" "ecr_read_only" {
  name = "ecr-read-only"
  role = aws_iam_role.ec2_pull.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
        Resource = var.ecr_repo_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2_pull.name
}

resource "aws_launch_template" "app" {
  # checkov:skip=CKV_AWS_88:public IPv4 on 8080 is the deliberate demo topology (no ALB/NAT cost); SSH stays restricted to admin CIDR
  name          = "${var.project}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    security_groups             = [var.security_group_id]
    associate_public_ip_address = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    region    = var.region
    ecr_repo  = var.ecr_repo
    ecr_image = var.ecr_image
  }))

  tags = { Name = "${var.project}-launch-template" }
}
