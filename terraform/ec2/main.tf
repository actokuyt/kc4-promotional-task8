resource "aws_instance" "minikube_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.public_subnet_id
  key_name        = var.key_name
  security_groups = [var.public_sg_id]

  associate_public_ip_address = true

  user_data = file("${path.module}/../scripts/main.sh")

  provisioner "file" {
    source      = "${path.module}/../../k8s"
    destination = "/home/ubuntu/app"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }



  tags = {
    Name = "minikube instance"
  }
}

