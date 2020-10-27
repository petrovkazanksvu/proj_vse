provider "aws" {
  region = "us-west-2"
}
/*resource "aws_instance" "example" {
  ami           = "ami-06e54d05255faf8f6"
  instance_type = "t2.micro"

  user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World" > index.html
             nohup busybox httpd -f -p ${var.server_port} &
             EOF

  tags = {
    Name = "terraform-example"
  }
  vpc_security_group_ids = [aws_security_group.instance.id]
}*/


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "Port to server"
  type        = number
  default     = 8081
}

variable "number_example" {
  description = "An example of a number variable in Terraform"
  type        = number
  default     = 42
}

variable "list_example" {
  description = "An example of a list in Terraform"
  type        = list
  default     = ["a", "b", "c"]
}

variable "list_numeric_example" {
  description = "An example of a numeric list in Terraform"
  type        = list(number)
  default     = [1, 2, 3]
}


/*output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}
*/


resource "aws_launch_configuration" "example" {
  image_id        = "ami-06e54d05255faf8f6"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World PETRA" > index.html
             nohup busybox httpd -f -p ${var.server_port} &
             EOF
}


resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 3

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
