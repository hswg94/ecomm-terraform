locals {
  api_domain      = "api.${var.domain_name}"
  frontend_domain = "ecomm.${var.domain_name}"
}

# VPC, public subnets and routing
module "network" {
  source = "./modules/network"
}

# Hosted zone, registered-domain name servers and ACM certificates
module "dns" {
  source          = "./modules/dns"
  domain_name     = var.domain_name
  api_domain      = local.api_domain
  frontend_domain = local.frontend_domain
}

# API runtime: security groups, EC2 launch template, ALB, Auto Scaling Group, api.* records
module "backend" {
  source          = "./modules/backend"
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.public_subnet_ids
  zone_id         = module.dns.zone_id
  certificate_arn = module.dns.alb_certificate_arn
  api_domain      = local.api_domain
}

# API CI/CD: GitHub -> CodePipeline -> CodeDeploy -> Auto Scaling Group
module "backend_cicd" {
  source               = "./modules/backend-cicd"
  artifact_bucket_name = var.ecomm-api-s3-for-cp
  connection_arn       = var.connection_arn
  repository_id        = "hswg94/ecomm-express-api"
  asg_name             = module.backend.asg_name
}

# Frontend hosting: S3 bucket, CloudFront, ecomm.* records
module "frontend" {
  source          = "./modules/frontend"
  bucket_name     = var.ecomm-frontend-s3-for-cb-and-cf
  zone_id         = module.dns.zone_id
  certificate_arn = module.dns.cloudfront_certificate_arn
  frontend_domain = local.frontend_domain
}

# Frontend CI/CD: GitHub -> CodeBuild -> S3 bucket
module "frontend_cicd" {
  source         = "./modules/frontend-cicd"
  bucket_name    = module.frontend.bucket_name
  connection_arn = var.connection_arn
  repository_url = "https://github.com/hswg94/ecomm-react-frontend"
}
