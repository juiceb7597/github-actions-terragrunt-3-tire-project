################################################################################
# Launch template
################################################################################

variable "create_launch_template" {
  description = "Controls if Launch template should be created"
  type        = bool
  # default     = true
}

variable "launch_template_name" {
  description = "Information for Launch template"
  type        = string
  # default     = ""
}

variable "launch_template_description" {
  description = "Information for Launch template"
  type        = string
  # default     = ""
}

variable "instance_type" {
  description = "The type of the instance"
  type        = string
  # default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  # default     = null
}

variable "user_data" {
  description = "The Base64-encoded user data to provide when launching the instance"
  type        = string
  # default     = null
}

variable "launch_template_tags" {
  description = "Additional information for the Launch template"
  type        = string
  # default     = ""
}

################################################################################
# Autoscaling group
################################################################################

variable "create_asg" {
  description = "Controls if Autoscaling Group should be created"
  type        = bool
  # default     = true
}

variable "asg_name" {
  description = "Information for Autoscaling Group"
  type        = string
  # default     = ""
}

variable "asg_tags" {
  description = "A list of tags to assign to Autoscaling group"
  type        = string
  # default     = ""
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  # default     = null
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  # default     = null
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  # default     = null
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  # default     = null
}

################################################################################
# Security Group
################################################################################

variable "db_sg_name" {
  description = "Information for DB Security Group"
  type        = string
  # default     = ""
}

variable "db_sg_description" {
  description = "Information for DB Security Group"
  type        = string
  # default     = ""
}


variable "db_sg_ports" {
  description = "List of allowed ports to DB Security Group"
  type        = map(any)
  # default     = {}
}

variable "sg_tags" {
  description = "Additional information for the Security Group"
  type        = string
  # default     = ""
}

################################################################################
# Common
################################################################################

variable "multi_az" {
  description = "Settings for HA"
  type        = bool
  # default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  # default     = ""
}

################################################################################
# Dependencies
################################################################################

variable "vpc_id" {
  description = "VPC ID of network module"
  type        = string
  # default     = ""
}

