# provider configuration
provider "aws" {
  region = "us-west-2"  # Specify your region
}

# VPC Module (You can reuse the same VPC as in the EKS example or create a new one)
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "ecs-vpc"
  cidr   = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

# ECS Cluster Module
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = "my-ecs-cluster"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # Optionally, you can configure an ECS Fargate service or EC2 launch type
  launch_type = "FARGATE"

  cluster_capacity_providers = ["FARGATE"]

  # Example task definition
  task_definition = {
    family                   = "my-task-family"
    network_mode             = "awsvpc"
    container_definitions    = jsonencode([{
      name      = "my-container"
      image     = "nginx:latest"
      essential = true
      memory    = 512
      cpu       = 256
    }])
  }
}

# Output ECS Cluster details
output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
