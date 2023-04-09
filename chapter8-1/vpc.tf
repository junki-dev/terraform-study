resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "inflearn-terraform-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
#   availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "inflearn-terraform-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "inflearn-terraform-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "inflearn-terraform-igw"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
      allocation_id = aws_eip.nat.id

      # private subnet이 아니라 public subnet으로 연결해야 한다.
      subnet_id = aws_subnet.public_subnet.id

      tags = {
            "Name" = "inflearn-terraform-nat-gateway"
      }
}

resource "aws_route_table" "public_route_table" {
      vpc_id = aws_vpc.main.id

      # inner rules
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
      }

      tags = {
            Name = "inflearn-terraform-public-rt"
      } 
}

resource "aws_route_table" "private_route_table" {
      vpc_id = aws_vpc.main.id
      tags = {
            Name = "inflearn-terraform-private-rt"
      } 
}

resource "aws_route_table_association" "route_table_association_public" {
      subnet_id = aws_subnet.public_subnet.id
      route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association"  "route_table_association_private" {
      subnet_id = aws_subnet.private_subnet.id
      route_table_id = aws_route_table.private_route_table.id
}

# 바깥의 룰로도 추가 할 수 있다.
# inner rule 보다는 외부로 빼는 것이 확장성에 더 좋다.
resource "aws_route" "private_nat" {
      route_table_id = aws_route_table.private_route_table.id
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway.id
  
}

resource "aws_vpc_endpoint" "s3" {
      vpc_id = aws_vpc.main.id
      service_name =  "com.amazonaws.ap-northeast-2.s3"
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association_endpoint" {
      route_table_id = aws_route_table.public_route_table.id
      vpc_endpoint_id = aws_vpc_endpoint.s3.id
}