##### IAM ROLES AND POLICIES #####

### LAMBDA ROLE ###
resource "aws_iam_role" "iam_lambda_role" {
  name = "devsecops-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow",
	  "Sid": ""
	 }
  ]
}
EOF
}

#### LAMBDA POLICY ####

resource "aws_iam_policy" "iam_lambda_policy" {
  name         = "devsecops-lambda-policy"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": [
	  "logs:CreateLogGroup",
	  "logs:CreateLogStream",
	  "logs:PutLogEvents",
	  "securityhub:BatchImportFindings",
	  "lambda:InvokeFunction"
	],
	  "Resource": "*",
	  "Effect": "Allow"
	   }
	 ]
	}
EOF
}


resource "aws_iam_role_policy_attachment" "attach_lambda_policy_to_role" {
 role        = aws_iam_role.iam_lambda_role.name
 policy_arn  = aws_iam_policy.iam_lambda_policy.arn
}


#### IAM ROLE CODE BUILD ####

resource "aws_iam_role" "iam_codebuild_role" {
  name = "devsecops-codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


#### IAM POLICY CODE BUILD #### 

resource "aws_iam_role_policy" "iam_codebuild_policy" {
  role = aws_iam_role.iam_codebuild_role.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:ap-south-1:297621708399:Devsecops"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
POLICY
}
### attach lambda policy to code build role ###
resource "aws_iam_role_policy_attachment" "attach_codebuild_policy_to_role" {
 role        = aws_iam_role.iam_codebuild_role.name
 policy_arn  = aws_iam_policy.iam_lambda_policy.arn
}

### CODE PIPELINE ROLE ###

resource "aws_iam_role" "iam_codepipeline_role" {
  name = "devsecops-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

### CODE PIPELINE POLICY ###

resource "aws_iam_role_policy" "iam_codepipeline_policy" {
  name = "devsecops-codepipeline-policy"
  role = aws_iam_role.iam_codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.devsecops_s3.arn}",
        "${aws_s3_bucket.devsecops_s3.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
	{
	  "Action": [
		"iam:PassRole"
	  ],
	  "Resource": "*",
	  "Effect": "Allow",
	  "Condition": {
		"StringEqualsIfExists": {
			"iam:PassedToService": [
			"cloudformation.amazonaws.com",
			"elasticbeanstalk.amazonaws.com",
			"ec2.amazonaws.com",
			"ecs-tasks.amazonaws.com"
		  ]
		}
	  }
	},
	{
	  "Action": [
		"codecommit:CancelUploadArchive",
		"codecommit:GetBranch",
		"codecommit:GetCommit",
		"codecommit:GetRepository",
		"codecommit:GetUploadArchiveStatus",
		"codecommit:UploadArchive"
	  ],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"codedeploy:CreateDeployment",
		"codedeploy:GetApplication",
		"codedeploy:GetApplicationRevision",
		"codedeploy:GetDeployment",
		"codedeploy:GetDeploymentConfig",
		"codedeploy:RegisterApplicationRevision"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"elasticbeanstalk:*",
		"ec2:*",
		"elasticloadbalancing:*",
		"autoscaling:*",
		"cloudwatch:*",
		"s3:*",
		"sns:*",
		"cloudformation:*",
		"sqs:*",
		"ecs:*"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"lambda:InvokeFunction",
		"lambda:ListFunctions"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"opsworks:CreateDeployment",
		"opsworks:DescribeApps",
		"opsworks:DescribeCommands",
		"opsworks:DescribeDeployments",
		"opsworks:DescribeInstances",
		"opsworks:DescribeStacks",
		"opsworks:UpdateApp",
		"opsworks:UpdateStack"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"cloudformation:CreateStack",
		"cloudformation:DeleteStack",
		"cloudformation:DescribeStacks",
		"cloudformation:UpdateStack",
		"cloudformation:CreateChangeSet",
		"cloudformation:DeleteChangeSet",
		"cloudformation:DescribeChangeSet",
		"cloudformation:ExecuteChangeSet",
		"cloudformation:SetStackPolicy",
		"cloudformation:ValidateTemplate"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Action": [
		"codebuild:BatchGetBuilds",
		"codebuild:StartBuild",
		"codebuild:BatchGetBuildBatches",
		"codebuild:StartBuildBatch"
		],
	  "Resource": "*",
	  "Effect": "Allow"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"devicefarm:ListProjects",
		"devicefarm:ListDevicePools",
		"devicefarm:GetRun",
		"devicefarm:GetUpload",
		"devicefarm:CreateUpload",
		"devicefarm:ScheduleRun"
		],
	  "Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"servicecatalog:ListProvisioningArtifacts",
		"servicecatalog:CreateProvisioningArtifact",
		"servicecatalog:DescribeProvisioningArtifact",
		"servicecatalog:DeleteProvisioningArtifact",
		"servicecatalog:UpdateProduct"
		],
	  "Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"cloudformation:ValidateTemplate"
		],
	  "Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"ecr:DescribeImages"
		],
		"Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"states:DescribeExecution",
		"states:DescribeStateMachine",
		"states:StartExecution"
		],
	  "Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": [
		"appconfig:StartDeployment",
		"appconfig:StopDeployment",
		"appconfig:GetDeployment"
		],
	  "Resource": "*"
	}	
  ]
}
EOF
}
