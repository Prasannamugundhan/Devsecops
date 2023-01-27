output "ebs_endpoint_url_stage" {
  value       = aws_elastic_beanstalk_environment.devsecops_ebs_env_stage.endpoint_url
  description = "Elastic Beanstalk environment end url name"
}
output "ebs_endpoint_url_prod" {
  value       = aws_elastic_beanstalk_environment.devsecops_ebs_env_prod.endpoint_url
  description = "Elastic Beanstalk environment end url name"
}

