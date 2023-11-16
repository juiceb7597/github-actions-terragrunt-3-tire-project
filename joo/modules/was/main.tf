################################################################################
# Launch template
################################################################################

resource "aws_launch_template" "was" {
  count = var.create_launch_template ? 1 : 0

  name          = "${var.name}-${var.launch_template_name}"
  description   = "${var.name}-${var.launch_template_description}"
  instance_type = var.instance_type
  image_id      = data.aws_ami.amzlinux3.id
  key_name      = var.key_name
  user_data     = var.user_data

  vpc_security_group_ids = aws_security_group.was[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.launch_template_tags}" }
  )
}
################################################################################
# Autoscaling group
################################################################################

resource "aws_autoscaling_group" "this" {
  count = var.create_asg && var.create_launch_template ? 1 : 0

  name = "${var.name}-${var.asg_name}"

  launch_template {
    id = aws_launch_template.was[0].id
  }

  vpc_zone_identifier       = var.multi_az && var.create_asg ? var.vpc_zone_identifier : var.create_asg ? [var.vpc_zone_identifier[0]] : []
  min_size                  = var.multi_az && var.create_asg ? 2 : var.create_asg ? 1 : 0
  max_size                  = var.multi_az && var.create_asg ? 4 : var.create_asg ? 2 : 0
  desired_capacity          = var.multi_az && var.create_asg ? 2 : var.create_asg ? 1 : 0
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.asg_tags}"
    propagate_at_launch = true
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "was" {
  count = var.create_launch_template ? 1 : 0

  name        = "${var.name}-${var.was_sg_name}"
  description = "${var.name}-${var.was_sg_description}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.was_sg_ports
    content {
      description = "Allow ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    { "Name" = "${var.name}-${var.sg_tags}" }
  )
}