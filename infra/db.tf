#TODO Remove default name
resource "aws_db_subnet_group" "data_subnet_group" {
  name       = "data_subnet_group"
  subnet_ids = [aws_subnet.Cervian_data1.id, aws_subnet.Cervian_data2.id, aws_subnet.Cervian_data3.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.16"
  instance_class       = "db.t2.micro"
  name                 = "app"
  username             = "postgres"
  password             = "mysupersecretpassword"
  skip_final_snapshot  = true
  port                 = 5432
  db_subnet_group_name = aws_db_subnet_group.data_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_postgres.id, aws_security_group.allow_http_ssh.id]
}


resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "postgres from app"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "http from internet"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # #Maybe remove this?
  # egress {
  #   description = "http from internet"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  tags = {
    Name = "Allow Postgres"
  }
}