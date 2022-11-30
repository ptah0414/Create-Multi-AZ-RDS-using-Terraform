provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  # version = "2.77.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

resource "aws_security_group" "rds" {
  name   = "education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "education_rds"
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "mysql5.7"
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  availability_zone = data.aws_availability_zones.available.names[0]
  allocated_storage      = 5
  backup_retention_period = 7
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_db_instance" "education_replica" {
   name                   = "education-replica"
   identifier             = "education-replica"
   availability_zone = data.aws_availability_zones.available.names[1]
   replicate_source_db    = aws_db_instance.education.identifier
   instance_class         = "db.t3.micro"
   apply_immediately      = true
   publicly_accessible    = true
   skip_final_snapshot    = true
   vpc_security_group_ids = [aws_security_group.rds.id]
   parameter_group_name   = aws_db_parameter_group.education.name
}

resource "aws_db_instance" "education_replica-2" {
   name                   = "education-replica-2"
   identifier             = "education-replica-2"
   availability_zone = data.aws_availability_zones.available.names[2]
   replicate_source_db    = aws_db_instance.education.identifier
   instance_class         = "db.t3.micro"
   apply_immediately      = true
   publicly_accessible    = true
   skip_final_snapshot    = true
   vpc_security_group_ids = [aws_security_group.rds.id]
   parameter_group_name   = aws_db_parameter_group.education.name
}

