variable "file_name" {
  type        = string
  default     = "imagedefinitions.json"
}

resource "aws_codepipeline" "pipeline" {
  name     = "wsc2024-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline.bucket
  }

  stage {
    name = "Source"

    action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit"
        version          = "1"
        output_artifacts = ["SourceArtifact"]
        namespace        = "NewCommit"
        configuration = {
            RepositoryName = aws_codecommit_repository.commit.repository_name
            BranchName = "master"
            PollForSourceChanges = "false"
            OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
  stage {
    name = "approval"
    action {
        name            = "approval"
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        version         = "1"
    configuration = {
      CustomData = "new CommitId : #{NewCommit.CommitId}"
      ExternalEntityLink = "https://us-west-1.console.aws.amazon.com/codesuite/codecommit/repositories/wsc2024-cci/commit/#{NewCommit.CommitId}?region=us-west-1"
        }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.deploy.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.deploy.deployment_group_name
        AppSpecTemplateArtifact        = "BuildArtifact"
        AppSpecTemplatePath            = "appspec.yml"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
        Image1ArtifactName             = "BuildArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}

resource "random_string" "wsc2024_random" {
  length           = 3
  upper   = false
  lower   = false
  numeric  = true
  special = false
}

resource "aws_s3_bucket" "pipeline" {
  bucket = "wsc2024-artifacts-${random_string.wsc2024_random.result}"
  force_destroy = true
}

data "aws_iam_policy_document" "assume_role_pipeline" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "wsi-role-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipeline.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:*",
      "codecommit:*",
      "codebuild:*",
      "logs:*",
      "codedeploy:*",
      "s3:*",
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_cloudwatch_event_rule" "event" {
  name = "wsi-ci-event"

  event_pattern = <<EOF
{
  "source": [ "aws.codecommit" ],
  "detail-type": [ "CodeCommit Repository State Change" ],
  "resources": [ "${aws_codecommit_repository.commit.arn}" ],
  "detail": {
     "event": [
       "referenceCreated",
       "referenceUpdated"
      ],
     "referenceType":["branch"],
     "referenceName": ["master"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "event" {
  target_id = "wsi-ci-event-target"
  rule = aws_cloudwatch_event_rule.event.name
  arn = aws_codepipeline.pipeline.arn
  role_arn = aws_iam_role.ci.arn
}

resource "aws_iam_role" "ci" {
  name = "wsi-ci"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ci" {
  statement {
    actions = [
      "iam:PassRole",
      "codepipeline:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ci" {
  name = "wsi-ci-policy"
  policy = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_role_policy_attachment" "ci" {
  policy_arn = aws_iam_policy.ci.arn
  role = aws_iam_role.ci.name
}