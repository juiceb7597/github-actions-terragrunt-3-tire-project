terraform {
  source = "../../../modules/was"
}

dependency "network" {
  config_path                             = "../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id      = "vpc-mockid"
    was_subnets = ["subnet-mockid1", "subnet-mockid2"]
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
  vpc_zone_identifier         = dependency.network.outputs.was_subnets
  launch_template_name        = "was-launch-template"
  launch_template_description = "was-launch-template"
  instance_type               = "t3.micro"
  key_name                    = "juiceb"
  user_data                   = filebase64("./was-install.sh")
  launch_template_tags        = "launch-template"

  ################################################################################
  # Autoscaling group
  ################################################################################
  create_asg                = true # If the create_launch_template is false, then this will not Autoscaling Group
  asg_name                  = "was-asg"
  asg_tags                  = "was"
  wait_for_capacity_timeout = "5m"
  health_check_type         = "EC2"
  health_check_grace_period = 180

  ################################################################################
  # Security Group
  ################################################################################

  vpc_id             = dependency.network.outputs.vpc_id
  was_sg_name        = "was-sg"
  was_sg_description = "was-sg"
  was_sg_ports = {
    tomcat = "8080"
  }
  sg_tags = "was-sg"
}