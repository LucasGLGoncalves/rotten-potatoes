# EC2 pública (aplicação)
resource "aws_instance" "app" {
  ami             = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.app_sg.id ]
  key_name        = "minha-chave-ssh"
  security_groups = [aws_security_group.app_sg.id]
  tags            = { Name = "app-server" }
}

# EC2 privada (banco de dados)
resource "aws_instance" "db" {
  ami             = "ami-0c02fb55956c7d316"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = "minha-chave-ssh"
  security_groups = [aws_security_group.db_sg.id]
  tags            = { Name = "db-server" }
}