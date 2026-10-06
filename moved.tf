# State migration from the flat root module into ./modules.
# Each block tells Terraform an existing resource now lives at a new address, so nothing is recreated.
# Safe to delete after the first successful apply with these blocks in place.

////////////////////////////////////////////////////////////////////
// network

moved {
  from = aws_vpc.MyFypVpc
  to   = module.network.aws_vpc.this
}

moved {
  from = aws_internet_gateway.igw
  to   = module.network.aws_internet_gateway.this
}

moved {
  from = aws_subnet.public-subnet-1
  to   = module.network.aws_subnet.public["1"]
}

moved {
  from = aws_subnet.public-subnet-2
  to   = module.network.aws_subnet.public["2"]
}

moved {
  from = aws_route_table.public-rt
  to   = module.network.aws_route_table.public
}

moved {
  from = aws_route_table_association.public-subnet-association-1
  to   = module.network.aws_route_table_association.public["1"]
}

moved {
  from = aws_route_table_association.public-subnet-association_2
  to   = module.network.aws_route_table_association.public["2"]
}

////////////////////////////////////////////////////////////////////
// dns

moved {
  from = aws_route53_zone.primary
  to   = module.dns.aws_route53_zone.this
}

moved {
  from = aws_route53domains_registered_domain.update-domain-ns
  to   = module.dns.aws_route53domains_registered_domain.this
}

moved {
  from = aws_acm_certificate.ap-southeast-1-cert
  to   = module.dns.aws_acm_certificate.alb
}

moved {
  from = aws_acm_certificate_validation.ap-southeast-1-cert
  to   = module.dns.aws_acm_certificate_validation.alb
}

moved {
  from = aws_route53_record.cert-validation-ap-southeast-1
  to   = module.dns.aws_route53_record.alb_cert_validation
}

moved {
  from = aws_acm_certificate.us-east-1-cert
  to   = module.dns.aws_acm_certificate.cloudfront
}

moved {
  from = aws_acm_certificate_validation.us-east-1-cert
  to   = module.dns.aws_acm_certificate_validation.cloudfront
}

moved {
  from = aws_route53_record.cert-validation-us-east-1
  to   = module.dns.aws_route53_record.cloudfront_cert_validation
}

////////////////////////////////////////////////////////////////////
// backend

moved {
  from = aws_security_group.alb-sg
  to   = module.backend.aws_security_group.alb
}

moved {
  from = aws_security_group.ec2-sg
  to   = module.backend.aws_security_group.ec2
}

moved {
  from = aws_iam_role.EC2AccessSMandCDRole
  to   = module.backend.aws_iam_role.ec2
}

moved {
  from = aws_iam_role_policy_attachment.AttachSecretsManagerReadWritePolicy
  to   = module.backend.aws_iam_role_policy_attachment.ec2["SecretsManagerReadWrite"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachCodeDeployServiceRolePolicy
  to   = module.backend.aws_iam_role_policy_attachment.ec2["AmazonEC2RoleforAWSCodeDeploy"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachCloudWatchAgentServerPolicyPolicy
  to   = module.backend.aws_iam_role_policy_attachment.ec2["CloudWatchAgentServerPolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachCloudWatchLogs
  to   = module.backend.aws_iam_role_policy_attachment.ec2["CloudWatchLogsFullAccess"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachAmazonSSMManagedInstanceCore
  to   = module.backend.aws_iam_role_policy_attachment.ec2["AmazonSSMManagedInstanceCore"]
}

moved {
  from = aws_iam_instance_profile.EC2AccessSMandCDInstanceProfile
  to   = module.backend.aws_iam_instance_profile.ec2
}

moved {
  from = aws_ssm_parameter.cloudwatch_agent_config
  to   = module.backend.aws_ssm_parameter.cloudwatch_agent_config
}

moved {
  from = aws_launch_template.ecomm-api-lt
  to   = module.backend.aws_launch_template.api
}

moved {
  from = aws_lb.ecomm-api-alb
  to   = module.backend.aws_lb.api
}

moved {
  from = aws_lb_target_group.ecomm-api-tg
  to   = module.backend.aws_lb_target_group.api
}

moved {
  from = aws_lb_listener.ecomm-api-listener
  to   = module.backend.aws_lb_listener.https
}

moved {
  from = aws_autoscaling_group.ecomm-api-asg
  to   = module.backend.aws_autoscaling_group.api
}

moved {
  from = aws_autoscaling_policy.ecomm-api-asg-policy
  to   = module.backend.aws_autoscaling_policy.cpu
}

moved {
  from = aws_route53_record.api-backend-endpoint
  to   = module.backend.aws_route53_record.api
}

moved {
  from = aws_route53_record.api-backend-endpoint_cname
  to   = module.backend.aws_route53_record.api_www
}

////////////////////////////////////////////////////////////////////
// backend-cicd

moved {
  from = aws_s3_bucket.ecomm-api-s3-for-cp
  to   = module.backend_cicd.aws_s3_bucket.artifacts
}

moved {
  from = aws_s3_bucket_public_access_block.ecomm-api-bucket-pab
  to   = module.backend_cicd.aws_s3_bucket_public_access_block.artifacts
}

moved {
  from = aws_codedeploy_app.ecomm-api
  to   = module.backend_cicd.aws_codedeploy_app.api
}

moved {
  from = aws_codedeploy_deployment_group.ecomm-api-dg
  to   = module.backend_cicd.aws_codedeploy_deployment_group.api
}

moved {
  from = aws_iam_role.CodeDeployRole
  to   = module.backend_cicd.aws_iam_role.codedeploy
}

moved {
  from = aws_iam_role_policy_attachment.AttachAmazonEC2FullAccess
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codedeploy["AmazonEC2FullAccess"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachAutoScalingFullAccess
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codedeploy["AutoScalingFullAccess"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachIAMFullAccess
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codedeploy["IAMFullAccess"]
}

moved {
  from = aws_iam_role.CodePipelineRole
  to   = module.backend_cicd.aws_iam_role.codepipeline
}

moved {
  from = aws_iam_role_policy.AttachCodeConnectionsToCodePipeline
  to   = module.backend_cicd.aws_iam_role_policy.codepipeline_connections
}

moved {
  from = aws_iam_role_policy_attachment.AttachCodeDeploytoCodePipeline
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codepipeline["AWSCodeDeployFullAccess"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachKMStoCodePipeline
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codepipeline["AWSKeyManagementServicePowerUser"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachS3toCodePipeline
  to   = module.backend_cicd.aws_iam_role_policy_attachment.codepipeline["AmazonS3FullAccess"]
}

moved {
  from = aws_codepipeline.ecomm-api-pl
  to   = module.backend_cicd.aws_codepipeline.api
}

////////////////////////////////////////////////////////////////////
// frontend

moved {
  from = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf
  to   = module.frontend.aws_s3_bucket.site
}

moved {
  from = aws_s3_bucket_public_access_block.ecomm-frontend-bucket-pab
  to   = module.frontend.aws_s3_bucket_public_access_block.site
}

moved {
  from = aws_s3_bucket_policy.allow-cloudfront-access
  to   = module.frontend.aws_s3_bucket_policy.site
}

moved {
  from = aws_cloudfront_origin_access_control.oac-for-s3
  to   = module.frontend.aws_cloudfront_origin_access_control.site
}

moved {
  from = aws_cloudfront_distribution.s3-distribution
  to   = module.frontend.aws_cloudfront_distribution.site
}

moved {
  from = aws_route53_record.frontend-endpoint
  to   = module.frontend.aws_route53_record.frontend
}

moved {
  from = aws_route53_record.frontend-endpoint_cname
  to   = module.frontend.aws_route53_record.frontend_www
}

////////////////////////////////////////////////////////////////////
// frontend-cicd

moved {
  from = aws_iam_role.CodeBuildRole
  to   = module.frontend_cicd.aws_iam_role.codebuild
}

moved {
  from = aws_iam_role_policy.AttachCodeConnectionsToCodeBuild
  to   = module.frontend_cicd.aws_iam_role_policy.codebuild_connections
}

moved {
  from = aws_iam_role_policy_attachment.AttachKMStoCodeBuild
  to   = module.frontend_cicd.aws_iam_role_policy_attachment.codebuild["AWSKeyManagementServicePowerUser"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachS3toCodeBuild
  to   = module.frontend_cicd.aws_iam_role_policy_attachment.codebuild["AmazonS3FullAccess"]
}

moved {
  from = aws_iam_role_policy_attachment.AttachCloudWatchLogstoCodeBuild
  to   = module.frontend_cicd.aws_iam_role_policy_attachment.codebuild["CloudWatchLogsFullAccess"]
}

moved {
  from = aws_codebuild_source_credential.codebuild-credentials
  to   = module.frontend_cicd.aws_codebuild_source_credential.github
}

moved {
  from = aws_codebuild_project.ecomm-frontend-builder
  to   = module.frontend_cicd.aws_codebuild_project.frontend
}

moved {
  from = terraform_data.initial_codebuild_trigger
  to   = module.frontend_cicd.terraform_data.initial_build
}
