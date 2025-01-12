provider "aws" {
    alias = "ap_south_1"
    region = "ap-south-1"
}

provider "aws" {
    alias = "us_east_1"
    region = "us-east-1"
}

# Create VPC for ap-south-1
resource "aws_vpc" "three-tier-app-vpc-ap-south-1"{
    provider = aws.ap_south_1
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {"Name" = "three-tier-app-vpc-ap-south-1"}
}

# Create VPC for us-east-1
resource "aws_vpc" "three-tier-app-vpc-us-east-1"{
    provider = aws.us_east_1
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {"Name" = "three-tier-app-vpc-us-east-1"}
}

# Public Subnet ap-south-1
resource "aws_subnet" "public_subnet_ap_south_1" {
    count = 2
    provider = aws.ap_south_1
    vpc_id = aws_vpc.three-tier-app-vpc-ap-south-1.id
    cidr_block = cidrsubnet(aws_vpc.three-tier-app-vpc-ap-south-1.cidr_block, 3, count.index)
    map_public_ip_on_launch = true
    availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
    tags = {"Name" = "Public Subnet ${count.index} ap-south-1"}
}

# Private Subnet ap-south-1
resource "aws_subnet" "private_subnet_ap_south_1" {
    count = 6
    provider = aws.ap_south_1
    vpc_id = aws_vpc.three-tier-app-vpc-ap-south-1.id
    cidr_block = cidrsubnet(aws_vpc.three-tier-app-vpc-ap-south-1.cidr_block, 3, count.index + 2)
    availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index % 2)
    tags = {
      "Name" = "Private Subnet ${count.index} ap-south-1"
    }
}

# Public Subnet us-east-1
resource "aws_subnet" "public_subnet_us_east_1" {
    count = 2
    provider = aws.us_east_1
    vpc_id = aws_vpc.three-tier-app-vpc-us-east-1.id
    cidr_block = cidrsubnet(aws_vpc.three-tier-app-vpc-us-east-1.cidr_block, 3, count.index)
    availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
    tags = {
      "Name" = "Public Subnet ${count.index} us-east-1"
    }
}

resource "aws_subnet" "private_subnet_us_east_1" {
    count = 6
    provider = aws.us_east_1
    vpc_id = aws_vpc.three-tier-app-vpc-us-east-1.id
    cidr_block = cidrsubnet(aws_vpc.three-tier-app-vpc-us-east-1.cidr_block, 3, count.index + 2)
    availability_zone = element(["us-east-1a", "us-east-1b"], count.index % 2)
    tags = {
      "Name" = "Private Subnet ${count.index} us-east-1"
    }
}
# Create Internet Gateways for ap-south-1
resource "aws_internet_gateway" "three-tier-app-IGW-ap-south-1" {
    provider = aws.ap_south_1
    vpc_id = aws_vpc.three-tier-app-vpc-ap-south-1.id
    tags = {"Name" = "three-tier-app-IGW-ap-south-1"}
}

# Create Internet Gateways for us-east-1
resource "aws_internet_gateway" "three-tier-app-IGW-us-east-1" {
    provider = aws.us_east_1
    vpc_id = aws_vpc.three-tier-app-vpc-us-east-1.id
    tags = {"Name" = "three-tier-app-IGW-us-east-1"}
}

# Create EIP for both region
resource "aws_eip" "nat_eip_app_south_1" {
    provider = aws.ap_south_1
    tags = {"Name" = "nat_eip_app_south_1"}
}

resource "aws_eip" "nat_eip_us_east_1" {
    provider = aws.us_east_1
    tags = {"Name" = "nat_eip_us_east_1"}  
}

# Create NAT Gateway for both region
resource "aws_nat_gateway" "three-tier-app-NAT-ap-south-1" {
    provider = aws.ap_south_1
    allocation_id = aws_eip.nat_eip_app_south_1
    subnet_id = aws_subnet.public_subnet_ap_south_1[0].id
    tags = {"Name" = "three-tier-app-NAT-ap-south-1"}  
}

resource "aws_nat_gateway" "three-tier-app-NAT-us-east-1" {
    provider = aws.us_east_1
    allocation_id = aws_eip.nat_eip_us_east_1.id
    subnet_id = aws_subnet.public_subnet_us_east_1[0].id
    tags = {"Name" = "three-tier-app-NAT-us-east-1"}
}

# Route Tables ap-south-1
resource "aws_route_table" "pub_rt_ap_south_1" {
    provider = aws.ap_south_1
    vpc_id = aws_vpc.three-tier-app-vpc-ap-south-1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.three-tier-app-IGW-ap-south-1.id
    }
    tags = {"Name" = "pub_rt_ap_south_1"}
}

resource "aws_route_table" "pri_rt_ap_south_1" {
    provider = aws.ap_south_1
    vpc_id = aws_vpc.three-tier-app-vpc-ap-south-1.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.three-tier-app-NAT-ap-south-1.id
    }
    tags = {"Name" = "pri_rt_ap_south_1"}
}

# Route Tables us-east-1
resource "aws_route_table" "pub_rt_us_east_1" {
    provider = aws.us_east_1
    vpc_id = aws_vpc.three-tier-app-vpc-us-east-1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.three-tier-app-IGW-us-east-1.id
    }
    tags = {"Name" = "pub_rt_us_east_1"}
}

resource "aws_route_table" "pri_rt_us_east_1" {
    provider = aws.us_east_1
    vpc_id = aws_vpc.three-tier-app-vpc-us-east-1.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.three-tier-app-NAT-us-east-1.id
    }
}

# Route Table associations
resource "aws_route_table_association" "pub_rt_assoc_ap_south_1" {
    count = 2
    provider = aws.ap_south_1
    subnet_id = aws_subnet.public_subnet_ap_south_1[count.index].id
    route_table_id = aws_route_table.pub_rt_ap_south_1.id
}

resource "aws_route_table_association" "pri_rt_assoc_ap_south_1" {
    count = 6
    provider = aws.ap_south_1
    subnet_id = aws_subnet.private_subnet_ap_south_1[count.index].id
    route_table_id = aws_route_table.pri_rt_ap_south_1.id
}

resource "aws_route_table_association" "pub_rt_assoc_us_east_1" {
    count = 2
    provider = aws.us_east_1
    subnet_id = aws_subnet.public_subnet_us_east_1[count.index].id
    route_table_id = aws_route_table.pub_rt_ap_south_1.id  
}

resource "aws_route_table_association" "pri_rt_assoc_us_east_1" {
    count = 6
    provider = aws.us_east_1
    subnet_id = aws_subnet.private_subnet_us_east_1[count.index].id
    route_table_id = aws_route_table.pri_rt_us_east_1.id
}