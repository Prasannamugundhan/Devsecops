
resource "aws_s3_bucket" "devsecops_s3" {
  bucket = "codepipelinedevsecopspoc"

  tags = {
    Name        = "devsecops bucket"
    Environment = "POC"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.devsecops_s3.id
  acl    = "private"
}

#### Create EBS application ####
resource "aws_elastic_beanstalk_application" "devsecops_ebs" {
  name        = "devsecops-ebs-app"
  description = "ebs Application"
}

#### Create EBS environment stage & Prod ####
resource "aws_elastic_beanstalk_environment" "devsecops_ebs_env_stage" {
  name                = "devsecops-env-stage"
  application         = aws_elastic_beanstalk_application.devsecops_ebs.name
  solution_stack_name= "64bit Amazon Linux 2 v4.3.0 running Tomcat 8.5 Corretto 11"
  tier  = "WebServer"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = aws_vpc.devsecops_vpc.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.devsecops_subnet.id},${aws_subnet.devsecops_subnet_1.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.devsecops_subnet.id},${aws_subnet.devsecops_subnet_1.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "2"
  }
}
resource "aws_elastic_beanstalk_environment" "devsecops_ebs_env_prod" {
  name                = "devsecops-env-prod"
  application         = aws_elastic_beanstalk_application.devsecops_ebs.name
  solution_stack_name= "64bit Amazon Linux 2 v4.3.0 running Tomcat 8.5 Corretto 11"
  tier  = "WebServer"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = aws_vpc.devsecops_vpc.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.devsecops_subnet.id},${aws_subnet.devsecops_subnet_1.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.devsecops_subnet.id},${aws_subnet.devsecops_subnet_1.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "2"
  }
}

#### Lambda Function ####

resource "aws_lambda_function" "lambda_function" {
        function_name = "ImportVulToSecurityHub"
        filename      = "Lambda-function.zip"
        role          = aws_iam_role.iam_lambda_role.arn
        runtime       = "python3.9"
        handler       = "import_findings_security_hub.lambda_handler"
        timeout       = 600
}

#### Enable security hub ####

resource "aws_securityhub_account" "devsecops_securityhub" {}

#### SNS ####

locals {
  emails = ["angela.selvinroy@aspiresys.com"]
}

resource "aws_sns_topic" "devsecops_sns_topic" {
  name            = "devsecops-topic"
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
}

resource "aws_sns_topic_subscription" "sns_email_subscription" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.devsecops_sns_topic.arn
  protocol  = "email"
  endpoint  = local.emails[count.index]
}
