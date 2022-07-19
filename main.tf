resource "aws_vpc" "vpc_prd" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "VPC producao"
  }
}

resource "aws_internet_gateway" "igw-rds" {
  vpc_id = aws_vpc.vpc_prd.id
  tags = {
    Name = "internet gateway"
  }
}

resource "aws_route_table" "tabela-rota" {
  vpc_id = aws_vpc.vpc_prd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-rds.id
  }

  tags = {
    Name = "tabela de rota"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.vpc_prd.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.vpc_prd.id 
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.vpc_prd.id 
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.vpc_prd.id 
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "permitir_aceeso_rds" {
  name        = "permitir_rds"
  description = "Permite acesso ao banco de dados mysql"
  vpc_id      = aws_vpc.vpc_prd.id


  ingress {
    description = "RDS acesso"
    from_port   = 3306
    to_port     = 3306
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
    Name = "permitir_aceeso_rds"
  }
}

resource "aws_db_instance" "banco" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  port = "3306"
  db_name = "aula"
  username = "admin"
  password = "XXXXXX"
  #availability_zone = "us-east-1"
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.permitir_aceeso_rds.id]
}

resource "aws_db_subnet_group" "db_subnet" {
  name = "dbsubnet"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  #subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}