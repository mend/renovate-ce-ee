variable "aws_creds_file" {
  description = "AWS Credentials File"
}

variable "aws_profile" {
  description = "AWS Profile"
}

variable "aws_region" {
  description = "Region where instances get created"
}

variable "aws_vpc_id" {
  description = "The VPC ID where the instances should reside"
}

variable "aws_subnet_id" {
  description = "The subnet-id to be used for the instance"
}

variable "aws_ssh_key_name" {
  description = "The SSH key to be used for the instances"
}

variable "services_ami" {
  description = "Override AMI lookup with provided AMI ID"
  default     = ""
}

variable "services_instance_type" {
  description = "Instance type for the EC2 Renovate runs on.  We recommend a t2 instance"
  default     = "t2.2xlarge"
}

variable "prefix" {
  description = "prefix for resource names"
  default     = "renovate"
}

variable "services_disable_api_termination" {
  description = "Enable or disable service box termination prevention"
  default     = "true"
}

variable "services_user_data_enabled" {
  description = "Disable User Data for Services Box"
  default     = "1"
}

variable "services_delete_on_termination" {
  description = "Configures AWS to delete the ELB volume for the Renovate box upon instance termination."
  default     = "false"
}

variable "ubuntu_ami" {
  default = {
    us-west-2      = "ami-c59ce2bd"
  }
}
