resource "aws_key_pair" "kpadnan" {
  key_name   = "kpadnan"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJS9xxe3zsDMnKsB+ae/Bcn+cCSnhw9kjqdXAP1Xz2ZW asus@Adnan"
}

resource "aws_instance" "ec2-adnan" {
  ami           = "ami-0030e4319cbf4dbf2"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.kpadnan.key_name

  subnet_id       = aws_subnet.privatesubnet-adnan.id
  vpc_security_group_ids = [aws_security_group.ec2-sg-adnan.id]

  instance_initiated_shutdown_behavior = "stop"
}