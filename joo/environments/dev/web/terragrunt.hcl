terraform {
  source = "../../../modules/web"
}

dependency "network" {
  config_path                             = "../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id      = "vpc-mockid"
    web_subnets = ["subnet-mockid1", "subnet-mockid2"]
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
  vpc_zone_identifier         = dependency.network.outputs.web_subnets
  launch_template_name        = "web-launch-template"
  launch_template_description = "web-launch-template"
  instance_type               = "t3.micro"
  key_name                    = "juiceb"
  user_data                   = filebase64("./web-install.sh")
  launch_template_tags        = "launch-template"

  ################################################################################
  # Autoscaling group
  ################################################################################
  create_asg                = true # If the create_launch_template is false, then this will not Autoscaling Group
  asg_name                  = "web-asg"
  asg_tags                  = "web"
  wait_for_capacity_timeout = "5m"
  health_check_type         = "EC2"
  health_check_grace_period = 180

  ################################################################################
  # Security Group
  ################################################################################

  vpc_id             = dependency.network.outputs.vpc_id
  web_sg_name        = "web-sg"
  web_sg_description = "web-sg"
  web_sg_ports = {
    http  = "80"
    https = "443"
  }
  sg_tags = "web-sg"
}