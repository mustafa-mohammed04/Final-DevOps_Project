output "private-subnet-id" {
    value =  [for subnet in aws_subnet.private : subnet.id]

  
}

output "public-subnet-id" {
    value = aws_subnet.public.id
  
}
output "vpc_id" {
    value = aws_vpc.vpc-1.id
  
}
