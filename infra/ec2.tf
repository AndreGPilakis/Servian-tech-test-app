provider "aws" {
  version = "~> 2.23"
  region  = "us-east-1"
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  #Change your public key here if it is named differently.
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_https_ssh"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "app from internet"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_http_ssh"
  }
}

resource "aws_lb_target_group" "tech_test_app" {
  name     = "tech-test-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "web_attachement" {
  target_group_arn = aws_lb_target_group.tech_test_app.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_instance" "web" {

  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Cervian_private1.id
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_http_ssh.id]

  tags = {
    Name = "Tech test App"
  }
}

resource "aws_lb" "tech_test_app" {
  name               = "tech-test-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.Cervian_public1.id, aws_subnet.Cervian_public2.id, aws_subnet.Cervian_public3.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tech_test_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tech_test_app.arn
  }
}

resource "aws_launch_configuration" "tech_test_app" {
  name            = "web_config"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_http_ssh.id]

  key_name = aws_key_pair.deployer.key_name
}

