provider "aws" {
	region = "${var.aws_region}"
}

resource "aws_key_pair" "barlog_key" {
  key_name    = "barlog"
  public_key  = "${file(var.ssh_pubkey_file)}"
}

resource "aws_autoscaling_group" "balrog" {
	availability_zones   = ["${split(",", var.availability_zones)}"]
	name                 = "balrog"
	max_size             = "${var.asg_max}"
	min_size             = "${var.asg_min}"
	desired_capacity     = "${var.asg_desired}"
	force_delete         = true
	launch_configuration = "${aws_launch_configuration.balrog.name}"
	vpc_zone_identifier  = "${var.vpc_zone_identifier}"
  load_balancers       = ["${aws_elb.balrog.name}"]

	tag {
  	key                 = "Name"
  	value               = "balrog"
  	propagate_at_launch = "true"
	}

  tag {
    key                 = "Owner"
    value               = "${var.owner_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "balrog"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "balrog" {
	name_prefix    			   = "balrog-"
	image_id      			   = "${lookup(var.aws_amis, var.aws_region)}"
	instance_type 			   = "${var.instance_type}"
	security_groups 		   = ["${aws_security_group.balrog_sg.id}"]
	user_data       		   = "${file("userdata.sh")}"
	key_name        		   = "${aws_key_pair.barlog_key.key_name}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_elb" "balrog" {
  name                  = "balrog"
  subnets               = "${var.subnets}"
  security_groups       = ["${aws_security_group.balrog_elb.id}"]
  idle_timeout          = 1800

  listener {
    instance_port       = 8000
    instance_protocol   = "http"
    lb_port             = 443
    lb_protocol         = "https"
    ssl_certificate_id  = "${var.ssl_certificate_id}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

}

resource "aws_security_group" "balrog_elb" {
  name        = "balrog_elb_sg"
  description = "Allow 443 port"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "balrog_sg" {
	name        = "balrog_sg"
	description = "balrog related ports"
	vpc_id 		=  "${var.vpc_id}"

	# SSH access from anywhere
	ingress {
  	from_port   = 22
  	to_port     = 22
  	protocol    = "tcp"
  	cidr_blocks = ["10.0.0.0/16"]
	}

	ingress {
    from_port       = 8000
  	to_port         = 8000
  	protocol        = "tcp"
    security_groups = ["${aws_security_group.balrog_elb.id}"]
	}

	ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]
	}

	# outbound internet access
	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	}
}
