variable "aws_region" {
	description = "The AWS region to create things in"
	default = "us-east-1"
}

variable "aws_amis" {
	default = {
		"us-east-1" = "ami-6f117479"
	}
}

variable "vpc_id" {
	default = "vpc-55a42a30"
}
 
variable "vpc_zone_identifier" {
	default = ["subnet-361ff61d", "subnet-f603ac81"]
}

variable "subnets" {
	default = ["subnet-361ff61d", "subnet-f603ac81"]
}

variable "availability_zones" {
	default = "us-east-1a,us-east-1e"
}

variable "instance_type" {
	default = "t2.small"
}

variable "asg_min" {
	default = "1"
}

variable "asg_max" {
	default = "1"
}

variable "asg_desired" {
	default = "1"
}


variable "owner_name" {
	default = "ops@cliqz.com"
}

variable "ssl_certificate_id" {
    default = "arn:aws:iam::141047255820:server-certificate/star_cliqz_sha256"
}

variable "ssh_pubkey_file" {
    default = "~/.ssh/agent-us-east.pem.pub"
}