# backend "s3" {}: uncommented by Fase 3 after scripts/bootstrap-state.sh

terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source     = "../../modules/network"
  project    = var.project
  region     = var.region
  admin_cidr = var.admin_cidr
}

module "registry" {
  source  = "../../modules/registry"
  project = var.project
}

module "compute" {
  source            = "../../modules/compute"
  project           = var.project
  region            = var.region
  ami_id            = var.ami_id
  security_group_id = module.network.security_group_id
  ecr_repo          = module.registry.repository_url
  ecr_repo_arn      = module.registry.repository_arn
  ecr_image         = "${module.registry.repository_url}:${var.image_tag}"
}
