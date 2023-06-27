provider "aws" {
  region = "us-east-1"
}

locals {
  app_name = "webapp"
}

# Create a VPC
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
 
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "networking"
  }
}

# Create an Elastic Container Registry (ECR) repository
resource "aws_ecr_repository" "this" {
  name = local.app_name
}

# Create a Security Group
resource "aws_security_group" "ecs_service" {
  name        = "${local.app_name}-ecs-sg"
  description = "Allow traffic to ECS service"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "ecs_service_ingress" {
  security_group_id = aws_security_group.ecs_service.id

  type                      = "ingress"
  from_port                 = 3000 
  to_port                   = 3000 
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs_service_egress" {
  security_group_id = aws_security_group.ecs_service.id
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group" "alb" {
  name        = "${local.app_name}-alb-sg"
  description = "Allow traffic to ALB"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = 443 
  to_port     = 443 
  protocol    = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id

  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

# Configure subnets
resource "aws_subnet" "public1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.this.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.this.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-2"
  }
}

resource "aws_subnet" "private1" {
  cidr_block = "10.0.101.0/24"
  vpc_id     = aws_vpc.this.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private2" {
  cidr_block = "10.0.102.0/24"
  vpc_id     = aws_vpc.this.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-2"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.app_name}-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "public"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Create an Elastic IP for the NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# Create the NAT gateway and associate it with the Elastic IP and public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat-gateway"
  }
}

# Create a route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "private"
  }
}

# Create a route for the NAT gateway in the private route table
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint-sg"
  description = "Allow access to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

resource "aws_security_group_rule" "vpc_endpoint_ecs_ingress" {
  security_group_id = aws_security_group.vpc_endpoint.id

  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id  = aws_security_group.ecs_service.id
}

resource "aws_vpc_endpoint" "secretsmanager" {
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_id              = aws_vpc.this.id
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private1.id, aws_subnet.private2.id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-vpc-endpoint"
  }
}

# Outputs for other environments
output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_service.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}
