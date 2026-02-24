resource "aws_key_pair" "kpadnan" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "aws_instance" "ec2-adnan" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.kpadnan.key_name

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  instance_initiated_shutdown_behavior = "stop"

  user_data = <<-EOF
              #!/bin/bash
              set -o pipefail

              echo "===== Runtime user-data started ====="

              # Wait for Docker daemon
              until docker info >/dev/null 2>&1; do
                echo "Waiting for Docker..."
                sleep 3
              done

              cd /home/ubuntu/Web-App || exit 1

              # Start containers (offline-safe)
              docker compose up -d

              echo "===== Runtime user-data completed ====="
              EOF
}
