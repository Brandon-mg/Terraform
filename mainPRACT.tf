provider "aws" {
    region = "us-east-1"
    access_key = "//"
    secret_key = "//"
}

#vpc
resource "aws_vpc" "projvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "procution vpc"
    }
}
#internet gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.projvpc.id
}
#route table
resource "aws_route_table" "projrt" {
    vpc_id = aws_vpc.projvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}
#subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.projvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}
#associate subnet
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.projrt.id

}
#security group
resource "aws_security_group" "allowtls" {
    name = "allow traffic"
    description = "allows basic inbound trafic"
    vpc_id = aws_vpc.projvpc.id

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#network interface
resource "aws_network_interface" "test" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["10.0.1.50"]
    security_groups = [aws_security_group.allowtls.id]
}
#elastic ip
resource "aws_eip" "one" {
    vpc = true
    network_interface = aws_network_interface.test.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gw]
}
#ubuntu server
