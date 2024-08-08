resource "aws_nat_gateway" "main" {
  allocation_id = var.eip_id
  subnet_id     = var.subnet_id

  tags = {
    Name = "NAT"
  }
}