variable "region" {
  default = "ap-south-1"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "558811456770",
#    "888888888888",
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::558811456770:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"
      username = "raj00565@gmail.com"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}

variable "instance_type_1" {
  type        = string
  description = "instance Type"
  default = "t3.medium"
}

variable "instance_type_2" {
  type        = string
  description = "instance Type"
  default = "t3.small" 
}
variable "cluster_name" {
  type        = string
  description = "Cluster Name"
  default = "eks-demo"
}


variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default = "vpc-eks-testing"
}

variable "tag_environment" {
  type        = string
  description = "Environment Name"
  default = "testing"
}

variable "tag_GithubRepo" {
  type        = string
  description = "Environment Name"
  default = "testing-repo"
}

variable "tag_GithubOrg" {
  type        = string
  description = "Environment Name"
  default = "testing-github-org"
}

variable "s3bucket" {
  type        = string
  description = "terraform state s3 bucket"
  default = "s3"
}

variable "s3bucketkey" {
  type        = string
  description = "terraform state s3 files name prefix"
  default = "s3/state"
}

variable "vpc-subnet-cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "The VPC Subnet CIDR"
}

variable "private_subnets" {
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type        = list
  description = "Private Subnet CIDR"
}

variable "public_subnets" {
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type        = list
  description = "Public Subnet CIDR"
}

