terraform {
  source = "../../../modules/db"
}

dependency "network" {
  config_path                             = "../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id     = "vpc-mockid"
    db_subnets = ["subnet-mockid1", "subnet-mockid2"]
  }
}

include "envcommon" {
  path = "../env.hcl"
}

inputs = {
  ################################################################################
  # Launch template
  ################################################################################
  create_launch_template      = true
  vpc_zone_identifier         = dependency.network.outputs.db_subnets
  launch_template_name        = "db-launch-template"
  launch_template_description = "db-launch-template"
  instance_type               = "t3.micro"
  key_name                    = "juiceb"
  user_data                   = filebase64("./db-install.sh")
  launch_template_tags        = "launch-template"

  ################################################################################
  # Autoscaling group
  ################################################################################
  create_asg                = true # If the create_launch_template is false, then this will not Autoscaling Group
  asg_name                  = "db-asg"
  asg_tags                  = "db"
  wait_for_capacity_timeout = "5m"
  health_check_type         = "EC2"
  health_check_grace_period = 180

  ################################################################################
  # Security Group
  ################################################################################

  vpc_id            = dependency.network.outputs.vpc_id
  db_sg_name        = "db-sg"
  db_sg_description = "db-sg"
  db_sg_ports = {
    postgresql = "5432"
  }
  sg_tags = "db-sg"
}