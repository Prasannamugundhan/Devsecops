resource "aws_codebuild_project" "owasp_zap_codebuild" {
  name          = "owasp-zap-Analysis"
  description   = "to analyse the url"
  build_timeout = "30"
  service_role  = aws_iam_role.iam_codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "appurl"
      value = aws_elastic_beanstalk_environment.devsecops_ebs_env_stage.endpoint_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/Devsecops"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
    buildspec     = "devops/buildspec-owasp-zap.yml"
  }

  source_version = "master"

  tags = {
    Environment = "dev"
  }
}
