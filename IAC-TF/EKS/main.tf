
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.eks-cluster-name
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = var.private-subnets-id
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
   ]
}

 resource "aws_launch_template" "launch_template_eks_group_node" {
   instance_type = "t3.small"
   key_name              = "key-bastion"
   block_device_mappings {
      device_name = "/dev/sda1"
     ebs {
       volume_size = 15
     }
   }
}






// Worker Nodes

resource "aws_eks_node_group" "Worker" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.eks_node_group-worker
  node_role_arn   = aws_iam_role.role-WN.arn
  subnet_ids      = var.private-subnets-id
  launch_template {
     id      = aws_launch_template.launch_template_eks_group_node.id
     version = "1"
  
   }
  



  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}


