
resource "aws_vpc" "tes-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "tes-vpc"
  }
}


resource "aws_subnet" "tes-subnet_1" {
  vpc_id                  = aws_vpc.tes-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "tes-subnet_1"
  }
}
resource "aws_subnet" "tes-subnet_2" {
  vpc_id                  = aws_vpc.tes-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2b"
  tags = {
    Name = "tes-subnet_2"
  }
}

resource "aws_internet_gateway" "tes-igw" {
  vpc_id = aws_vpc.tes-vpc.id
  tags = {
    Name = "tes-igw"
  }
}

resource "aws_route_table" "tes-rt_pub" {
  vpc_id = aws_vpc.tes-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tes-igw.id
  }
  tags = {
    Name = "tes-rt_pub"
  }
}

resource "aws_route_table_association" "tes-rta_pub_1" {
  subnet_id      = aws_subnet.tes-subnet_1.id
  route_table_id = aws_route_table.tes-rt_pub.id
}

resource "aws_route_table_association" "tes-rta_pub_2" {
  subnet_id      = aws_subnet.tes-subnet_2.id
  route_table_id = aws_route_table.tes-rt_pub.id
}

resource "aws_network_acl" "tes-nacl" {
  vpc_id     = aws_vpc.tes-vpc.id
  subnet_ids = [aws_subnet.tes-subnet_1.id, aws_subnet.tes-subnet_2.id]
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "tes-nacl"
  }
}

resource "aws_security_group" "tes-sc_lb" {
  name        = "tes-sc_lb"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.tes-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tes-sc_instance" {
  name        = "tes-sc_instance"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.tes-vpc.id
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tes-sc_lb.id]
  }
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tes-sc_lb.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "tes-sc_instance"
  }
}

resource "aws_instance" "tes-server_1" {
  ami             = "ami-0d09654d0a20d3ae2"
  instance_type   = "t2.micro"
  key_name        = "nginx"
  security_groups = [aws_security_group.tes-sc_instance.id]
  subnet_id       = aws_subnet.tes-subnet_1.id
  availability_zone = "eu-west-2a"
  tags = {
    Name   = "tes-server_1"
    source = "terraform"
  }
}
# creating instance 2
 resource "aws_instance" "tes-server_2" {
  ami             = "ami-0d09654d0a20d3ae2"
  instance_type   = "t2.micro"
  key_name        = "nginx"
  security_groups = [aws_security_group.tes-sc_instance.id]
  subnet_id       = aws_subnet.tes-subnet_1.id
  availability_zone = "eu-west-2a"
  tags = {
    Name   = "tes-server_2"
    source = "terraform"
  }
}
# creating instance 3
resource "aws_instance" "tes-server_3" {
  ami             = "ami-0d09654d0a20d3ae2"
  instance_type   = "t2.micro"
  key_name        = "nginx"
  security_groups = [aws_security_group.tes-sc_instance.id]
  subnet_id       = aws_subnet.tes-subnet_2.id
  availability_zone = "eu-west-2b"
  tags = {
    Name   = "tes-server_3"
    source = "terraform"
  }
}

resource "local_file" "Ip_file" {
  filename = "host_inventory"
  content  = <<EOT
${aws_instance.tes-server_1.public_ip}
${aws_instance.tes-server_2.public_ip}
${aws_instance.tes-server_3.public_ip}
  EOT
}

# # creating ansible playbook
# resource "null_resource" "ansible" {
#   provisioner "local-exec" {
#     command = "ansible-playbook -i host_inventory main.yml"
#   }
#   depends_on = [aws_instance.tes-server_1, aws_instance.tes-server_2, aws_instance.tes-server_3]
# }

resource "aws_lb" "tes-lb" {
  name                       = "tes-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.tes-sc_lb.id]
  subnets                    = [aws_subnet.tes-subnet_1.id, aws_subnet.tes-subnet_2.id]
  enable_deletion_protection = false
  depends_on                 = [aws_instance.tes-server_1, aws_instance.tes-server_2, aws_instance.tes-server_3]
}

resource "aws_lb_target_group" "tes-tg" {
  name        = "tes-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tes-vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "tes-listener" {
  load_balancer_arn = aws_lb.tes-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tes-tg.arn
  }
}
# Create the listener rule
resource "aws_lb_listener_rule" "tes-listener-rule" {
  listener_arn = aws_lb_listener.tes-listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tes-tg.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


resource "aws_lb_target_group_attachment" "tes-tg_attachment_1" {
  target_group_arn = aws_lb_target_group.tes-tg.arn
  target_id        = aws_instance.tes-server_1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "tes-tg_attachment_2" {
  target_group_arn = aws_lb_target_group.tes-tg.arn
  target_id        = aws_instance.tes-server_2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "tes-tg_attachment_3" {
  target_group_arn = aws_lb_target_group.tes-tg.arn
  target_id        = aws_instance.tes-server_3.id
  port             = 80
}

