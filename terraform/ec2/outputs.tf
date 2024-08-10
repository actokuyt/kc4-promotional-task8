output "ec2_public_ip" {
  value = aws_instance.minikube_instance.public_ip
}
