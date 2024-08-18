module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster-test"
  cluster_version = "1.29"

  openid_connect_audiences        = ["sts.amazonaws.com"]
  enable_irsa                     = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  authentication_mode             = "API_AND_CONFIG_MAP"



  # Networking configuration.
  vpc_id     = "vpc-0fbe950501d1f5133"
  subnet_ids = ["subnet-0ea9578f3d7825a27", "subnet-0a444b818bc4afc82"]

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::470513171732:user/cicd-terraform"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
        admin-cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            
            type       = "cluster"
          }
        }
      }
    }
  }


  # EKS Managed Node Group configuration.
  eks_managed_node_groups = {
    eks-node = {
      min_size     = 1
      max_size     = 2
      desired_size = 1 

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        "eks.lcf.io/managed-by" = "eks"
      }
    }
  }

  # Clustrer add-ons configuration.
  cluster_addons = {
    coredns = {
      addon_version = "v1.11.1-eksbuild.4"
    }
    kube-proxy = {
      addon_version = "v1.29.0-eksbuild.1"
    }
    vpc-cni = {
      addon_version = "v1.16.0-eksbuild.1"
    }
  }

  # Additional security group rules for cluster security group ingress.
  # Additional security group rules for cluster security group ingress.
  cluster_security_group_additional_rules = {
    ingress = {
      description                   = "To internal cluster API on port 443"
      type                          = "ingress"
      from_port                     = 443
      to_port                       = 443
      protocol                      = "tcp"
      cidr_blocks                   = ["10.0.0.0/8"]
      source_cluster_security_group = true
    }
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Ssh ports"
      protocol                   = "tcp"
      from_port                  = 22
      to_port                    = 22
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {

    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all_udp = {
      description = "Node all udp ingress"
      protocol    = "udp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/8"]
    }
  }



  tags = local.tags
}
