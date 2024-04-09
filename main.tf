module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster-test"
  cluster_version = "1.25"

  openid_connect_audiences       = ["sts.amazonaws.com"]
  enable_irsa = true
  cluster_endpoint_public_access = true

  # Networking configuration.
  vpc_id                   = "vpc-02d1ab643dbf7d013"
  subnet_ids               = ["subnet-0709cad24966f4302", "subnet-0f2589345255277b9"]

  # EKS Managed Node Group configuration.
  eks_managed_node_groups = {
    eks-node = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
      
      labels = {
        "eks.lcf.io/managed-by" = "eks"
      }
    }
  }

  tags = local.tags
}