// modules

module "vpc" {
    source = "./Networking"
    vpc-cidr-block = "10.0.0.0/16"
    vpc-tag-name = "eks-vpc1"
    private-subnet-cidr = ["10.0.4.0/24", "10.0.5.0/24"]
    az = ["us-east-1a", "us-east-1b"]
    private-subnet-tag-name = ["private-s1", "private-s2"]
    public-subnet-cidr = "10.0.3.0/24"
    public-subnet-tag-name = "Public-subnet"
    igw-tag-name = "My-IGW"
    ngw-tag-name = "my-ngw"
    pub-rt-cidr = "0.0.0.0/0"
    pub-rt-tag-name = "Public-RT"
    private-rt-cidr = "0.0.0.0/0"
    private-rt-tag-name = "Private-RT"
  
}

module "eks-cluster" {
    source = "./EKS"
    private-subnets-id = module.vpc.private-subnet-id
    eks-cluster-name = "anubis-eksCluster"
    eks_node_group-worker = "Gro-worker"
  
}

module "EC2" {
    source = "./EC2-Machines"
    public-subnet-id = module.vpc.public-subnet-id
    vpc-id = module.vpc.vpc_id
  
}


