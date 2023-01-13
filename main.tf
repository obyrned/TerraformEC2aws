# Create a VPC
resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# public subnet
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}
#internet gateway
resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

#route table
resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-public_rt"
  }
}

#default route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

#route table association
resource "aws_route_table_association" "mtc_public_assoc" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

#security group ingress and egress
resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #don't care about security, might have to change IP.
    cidr_blocks = ["0.0.0.0/0"]
    #MacBook from YXE, OracleArm from Cloud
    #cidr_blocks = ["XXX.XXX.XXX.XXX/32", "XXX.XXX.XXX.XXX/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#generated my own key locally and pointed to it.
resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")

}

#provision three EC2 machines in datasources.tf
resource "aws_instance" "dev_node1" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "dev-node1"
  }
}

resource "aws_instance" "dev_node2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "dev-node2"
  }
}

resource "aws_instance" "dev_node3" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "dev-node3"
  }
}

  # root_block_device {
  #   volume_size = 10
  # }
