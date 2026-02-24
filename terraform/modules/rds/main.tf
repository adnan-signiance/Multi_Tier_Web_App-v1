resource "aws_db_instance" "rds-adnan" {
  allocated_storage     = 20
  max_allocated_storage = 100
  db_name               = var.db_name
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = "default.mysql8.0"
  skip_final_snapshot   = true

  publicly_accessible = false
  port                = 3306

  multi_az             = false
  db_subnet_group_name = var.db_subnet_group_name

  vpc_security_group_ids = var.vpc_security_group_ids

  deletion_protection = false
}