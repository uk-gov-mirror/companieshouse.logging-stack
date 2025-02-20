provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

data "aws_route53_zone" "zone" {
  name         = local.dns_zone_name
  private_zone = false
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "development-${var.region}.terraform-state.ch.gov.uk"
    key    = "aws-common-infrastructure-terraform/common-${var.region}/networking.tfstate"
    region = var.region
  }
}

module "prometheus" {
  source = "./module-prometheus"

  ami_version_pattern           = var.prometheus_ami_version_pattern
  discovery_availability_zones  = local.discovery_availability_zones
  dns_zone_id                   = data.aws_route53_zone.zone.zone_id
  dns_zone_name                 = local.dns_zone_name
  environment                   = var.environment
  instance_count                = var.prometheus_instance_count
  instance_type                 = var.prometheus_instance_type
  prometheus_cidrs              = local.administration_cidrs
  prometheus_service_group      = var.prometheus_service_group
  prometheus_service_user       = var.prometheus_service_user
  lvm_block_devices             = var.prometheus_lvm_block_devices
  placement_subnet_ids          = data.aws_subnet_ids.placement.ids
  prometheus_metrics_port       = var.prometheus_metrics_port
  region                        = var.region
  root_volume_size              = var.prometheus_root_volume_size
  service                       = var.service
  ssh_cidrs                     = local.administration_cidrs
  ssh_keyname                   = var.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
  vpc_id                        = data.aws_vpc.vpc.id
}
