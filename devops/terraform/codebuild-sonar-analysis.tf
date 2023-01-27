resource "aws_codebuild_project" "sonar_codebuild" {
  name          = "Sonarqube-Analysis"
  description   = "to analyse the quality of code"
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
      name  = "SonarQube_URL"
      value = "${var.sonarurl}"
    }

    environment_variable {
      name  = "SonarQube_Access_Token"
      value = "${var.sonartoken}"
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
    buildspec     = "devops/buildspec-sonarqube.yml"
  }

  source_version = "master"

  tags = {
    Environment = "dev"
  }
}
