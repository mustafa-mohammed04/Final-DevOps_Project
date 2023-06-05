// this Vpc

resource "aws_vpc" "vpc-1" {
    cidr_block = var.vpc-cidr-block

    tags = {
      Name = var.vpc-tag-name
    }
  
}

//// Subnets

##########################################################################
// Private Subnet

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = var.private-subnet-cidr[count.index]
  count = length(var.private-subnet-cidr)
  availability_zone = var.az[count.index]
  

  tags = {
    Name = var.private-subnet-tag-name[count.index]
  }
}

// Public Subnet

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc-1.id
  cidr_block = var.public-subnet-cidr

  tags = {
    Name = var.public-subnet-tag-name
  }
}

//// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = var.igw-tag-name
  }
}


// elastic-ip

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  vpc = true
}



//// NGW

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id     = aws_subnet.public.id            // resrc name of public

  tags = {
    Name = var.ngw-tag-name
  }
}





//// route tables

// public rt

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = var.pub-rt-cidr
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = var.pub-rt-tag-name
  }
}


// private rt

resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = var.private-rt-cidr
    nat_gateway_id  = aws_nat_gateway.ngw.id
  }


  tags = {
    Name = var.private-rt-tag-name
  }
}


//// route table assoc

// public RT-Ass

resource "aws_route_table_association" "pub-rts" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.pub-rt.id
}

// private RT-Ass

resource "aws_route_table_association" "priv-rts" {
  subnet_id      = aws_subnet.private[count.index].id
  count = length(var.private-subnet-cidr)
  route_table_id = aws_route_table.pri-rt.id
}
