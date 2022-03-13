#
# Provides a postgres rds that serves as the django db.
#

resource "aws_db_subnet_group" "_" {
  name       = "${var.app_name}-${var.stage}-db-group"
  subnet_ids = var.vpc_subnets # at least 2 are required

  tags = {
    Name = "${var.app_name}-${var.stage}-db-group"
  }
}

resource "aws_security_group" "_" {
  name        = "${var.app_name}-${var.stage}-postgres"
  description = "Allow postgres to receive connections"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow Connections from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    description = "Allow Connections to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

resource "aws_db_instance" "_" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.10"
  instance_class         = var.instance_type
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group._.name
  vpc_security_group_ids = [aws_security_group._.id]
  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
  skip_final_snapshot = true
}
