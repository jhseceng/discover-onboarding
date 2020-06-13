//
//
resource "aws_s3_bucket" "CloudTrail_bucket" {
  bucket                        = var.CloudTrailS3BucketName
  acl                           = "bucket-owner-full-control"
  force_destroy                 = true
  policy                        = data.aws_iam_policy_document.s3BucketACLPolicy.json

  region = var.aws_region

  lifecycle_rule {
    id = "bucketlifecycle"
    enabled = true
    expiration {
      days = var.CloudTrailS3LogExpiration
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.CloudTrail_bucket.id

  topic {
//    topic_arn = arn:aws:sns:eu-west-1:292230061137:cs-cloudconnect-aws-cloudtrail
    topic_arn = "arn:aws:sns:${var.aws_region}:292230061137:cs-cloudconnect-aws-cloudtrail"
//    topic_arn     = var.SnsTopicCloudTrail
    events        = ["s3:ObjectCreated:Put"]
  }
}


data "aws_iam_policy_document" "s3BucketACLPolicy" {
  statement {

    sid = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    principals  {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [
       "arn:aws:s3:::${var.CloudTrailS3BucketName}"
    ]
  }
  statement {

    sid = "AWSCloudTrailWrite20150319"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [
       "arn:aws:s3:::${var.CloudTrailS3BucketName}/AWSLogs/*/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}

//

resource "aws_iam_policy" "ReadS3CloudTrailFiles" {
  name                          = "iamPolicyFalconDiscoverAccess"
  description                   = "S3 access policy for role assumed by Falcon Discover"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
              "Action": [
                "s3:GetObject"

              ],
              "Effect": "Allow",
              "Resource": "arn:aws:s3:::${var.CloudTrailS3BucketName}/*",
              "Sid": ""
            }
  ]
}
EOF
}

data "aws_iam_policy_document" "FalconAssumeRolePolicyDocument" {
  statement {

    sid = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.CSAccountNumber}:role/${var.CSAssumingRoleName}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        var.ExternalID
      ]
    }
//    resources = [
//      "arn:aws:s3:::${var.CloudTrailS3BucketName}"
//    ]
  }
}

resource "aws_iam_role" "iamRole" {
  name = "FalconDiscoverS3AccessRole"
  description                   = "Role assumed by Falcon Discover to read logs from S3"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.FalconAssumeRolePolicyDocument.json
}

resource "aws_iam_role_policy_attachment" "iamPolicyCloudTrailS3AccessAttach" {
  role                      = aws_iam_role.iamRole.name
  policy_arn                = aws_iam_policy.ReadS3CloudTrailFiles.arn
}

resource "aws_cloudtrail" "crwd_trail" {
  name = var.CloudTrailName
  depends_on = [aws_s3_bucket.CloudTrail_bucket]
  event_selector {
    read_write_type = "WriteOnly"
    include_management_events = true
  }
  include_global_service_events = true
  enable_logging                = true
  is_multi_region_trail         = true
  s3_bucket_name                = var.CloudTrailS3BucketName
}




output "cloudtrail_bucket_region" {
  value = var.aws_region
}

output "external_id" {
  value = var.ExternalID
}

output "iam_role_arn" {
        value = aws_iam_role.iamRole.arn
}