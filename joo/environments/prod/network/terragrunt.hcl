terraform {
  source = "../../../modules/network"
}

include "envcommon" {
  path = "../env.hcl"
}

inputs = {

  ################################################################################
  # VPC
  ################################################################################
  create_vpc = true # must be true
  vpc_tags   = "vpc"
  cidr       = "192.168.0.0/16"

  ################################################################################
  # Public Subnets
  ################################################################################
  create_public_subnet    = true
  public_subnet_cidr      = ["192.168.0.0/24", "192.168.10.0/24"]
  public_subnet_tags      = ["ap-northeast-2a-public-subnet", "ap-northeast-2c-public-subnet"]
  public_route_table_tags = ["public-route-table"]

  ################################################################################
  # WEB Subnets
  ################################################################################
  create_web_subnet    = true # must be true
  web_subnet_cidr      = ["192.168.20.0/24", "192.168.30.0/24"]
  web_subnet_tags      = ["ap-northeast-2a-web-subnet", "ap-northeast-2c-web-subnet"]
  web_route_table_tags = ["private-route-table"]

  ################################################################################
  # WAS Subnets
  ################################################################################
  create_was_subnet = true
  was_subnet_cidr   = ["192.168.40.0/24", "192.168.50.0/24"]
  was_subnet_tags   = ["ap-northeast-2a-was-subnet", "ap-northeast-2c-was-subnet"]

  ################################################################################
  # DB Subnets
  ################################################################################
  create_db_subnet = true
  db_subnet_cidr   = ["192.168.60.0/24", "192.168.70.0/24"]
  db_subnet_tags   = ["ap-northeast-2a-db-subnet", "ap-northeast-2c-db-subnet"]

  ################################################################################
  # Internet Gateway
  ################################################################################
  igw_tags = ["igw"]

  ################################################################################
  # NAT Gateway
  ################################################################################
  create_nat_gateway = true # If the condition of create_public_subnet is false, then this will not create NAT Gateway
  nat_eip_tags       = ["ap-northeast-2a-eip", "ap-northeast-2c-eip"]
  nat_gateway_tags   = ["ap-northeast-2a-nat-gateway", "ap-northeast-2c-nat-gateway"]
}