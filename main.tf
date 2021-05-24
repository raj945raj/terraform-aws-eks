provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "aws_availability_zones" "available" {
}

locals {
#  cluster_name = "test-eks-${random_string.suffix.result}"
   cluster_name = var.cluster_name
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "./modules/vpc"
#  version = "~> 2.47"

  name                 = var.vpc_name
  cidr                 =  var.vpc-subnet-cidr
  azs                  = data.aws_availability_zones.available.names
#  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = var.private_subnets
#  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = var.tag_environment
    GithubRepo  = var.tag_GithubRepo
    GithubOrg   = var.tag_GithubOrg
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.instance_type_1
      additional_userdata           = "echo working"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = var.instance_type_2
      additional_userdata           = "echo working"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}
