data "aws_subnet" "subnet" {
  id = "${var.aws_subnet_id}"
}

data "template_file" "startup_template" {
  template = "${file("templates/service_user_data.tpl")}"

  vars {
    aws_region               = "${var.aws_region}"
    subnet_id                = "${var.aws_subnet_id}"
  }
}

provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_creds_file}"
  profile                 = "${var.aws_profile}"
}

resource "aws_security_group" "renovate_users_sg" {
  name        = "${var.prefix}_users_sg"
  description = "SG representing users of Renovate Pro"

  vpc_id = "${var.aws_vpc_id}"

  # Should probably be changed depending on your setup so that it isn't wide open
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    description = "SSH"
  }

  # Any incoming traffic
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    description = "All traffic for renovate app to /webhook"
  }

  # Any outgoing traffic
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    description = "All outbound traffic (updating Linux etc.)"
  }
}

resource "aws_instance" "renovate-ec2" {
  instance_type               = "${var.services_instance_type}"
  ami                         = "${var.services_ami != "" ? var.services_ami : lookup(var.ubuntu_ami, var.aws_region)}"
  key_name                    = "${var.aws_ssh_key_name}"
  subnet_id                   = "${var.aws_subnet_id}"
  # If in a enterprise environment, this may need to be set to false
  associate_public_ip_address = true
  user_data                   = "${ var.services_user_data_enabled ? data.template_file.startup_template.rendered : "" }"
  disable_api_termination     = "${var.services_disable_api_termination}"

  vpc_security_group_ids = [
    "${aws_security_group.renovate_users_sg.id}"
  ]

  tags {
    Name = "${var.prefix}_services"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "150"
    delete_on_termination = "${var.services_delete_on_termination}"
  }

  lifecycle {
    prevent_destroy = false
  }
}
