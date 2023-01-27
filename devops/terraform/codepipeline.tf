resource "aws_codepipeline" "code_pipeline" {
  name     = "Devsecops-pipeline"
  role_arn = aws_iam_role.iam_codepipeline_role.arn
  tags     = {
    Name = var.name
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "BranchName"           = var.repository_branch
        "PollForSourceChanges" = "false"
        RepositoryName         = var.repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeCommit"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "owasp-dc-Build"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.owasp_dc_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "OWASP-DC-Artifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 2
      version   = "1"
    }
  }
  stage {
    name = "Sonar-analysis"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.sonar_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "Sonar-Artifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 3
      version   = "1"
    }
  }
  stage {
    name = "Source-Build"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.source_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "Application-Artifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 4
      version   = "1"
    }
  }  
  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.devsecops_ebs.name
        EnvironmentName = aws_elastic_beanstalk_environment.devsecops_ebs_env_stage.name
      }
      input_artifacts = [
        "Application-Artifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ElasticBeanstalk"
      run_order        = 5
      version          = "1"
    }
  }

  stage {
    name = "ZAP-Analysis"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.owasp_zap_codebuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "ZAP-Artifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 6
      version   = "1"
    }
  }  
  stage {
	name = "Approve"

	action {
	  name     = "Approval"
	  category = "Approval"
	  owner    = "AWS"
	  provider = "Manual"
          run_order = 7
	  version  = "1"
 	  configuration = {
	    NotificationArn = aws_sns_topic.devsecops_sns_topic.arn
	    CustomData = "approve to deploy to prod"
	    ExternalEntityLink = aws_elastic_beanstalk_environment.devsecops_ebs_env_stage.endpoint_url
	    }
	  }
	}
  stage {
    name = "Prod-Deploy"
    action {
      category = "Deploy"
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.devsecops_ebs.name
        EnvironmentName = aws_elastic_beanstalk_environment.devsecops_ebs_env_prod.name
      }
      input_artifacts = [
        "Application-Artifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ElasticBeanstalk"
      run_order        = 8
      version          = "1"
    }
  }
}
