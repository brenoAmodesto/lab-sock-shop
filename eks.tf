module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"

  cluster_name    = "eks-demo"
  cluster_version = 1.29

  cluster_endpoint_public_access = true
  enable_irsa                    = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  control_plane_subnet_ids       = module.vpc.private_subnets
  eks_managed_node_groups = {
    eks_nodegroup_1 = {
      min_size       = 1
      max_size       = 5
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        dedicated = "elasticsearch"
      }
    }

    front_end = {
        min_size = 1
        max_size = 10
        desired_size = 1
        instance_types = ["t3.medium"]

        labels = {
          app = "frontend"
        }
    }

    prometheus = {
        min_size = 1
        max_size = 10
        desired_size = 1
        instance_types = ["t3.medium"]

        labels = {
          mon = "prometheus"
        }
    }
  }
  

  node_security_group_tags = {
    "karpenter.sh/discovery" = "eks-demo"
  }
  authentication_mode = "API"
  # authentication_mode = "API_AND_CONFIG_MAP"
  # With API Auth, creator no longer has cluster access, and users must be created.
  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::471112841349:user/brenoamodesto@outlook.com"
      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
