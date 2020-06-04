
resource "aws_iam_role" "iamRole" {
  name = "iamRole"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${var.CSAccountNumber}:role/${var.CSAssumingRoleName}" }
      }]
  })
}

resource "aws_iam_policy" "iamPolicyDescribeAccess" {
  name        = "DescribeAPICalls"
  path        = "/"
  description = "Role assumed by crowdstrike"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
              "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcs",
                "ec2:DescribeRegions",
                "ec2:DescribeSubnets",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeSecurityGroups",
                "iam:ListAccountAliases"
              ],
              "Effect": "Allow",
              "Resource": "*",
              "Sid": ""
            }
  ]
}
EOF
}

resource "aws_iam_policy" "iamPolicyCloudTrailS3Access" {
count                         = var.EnableNewCloudTrail ? 1 : 0
  name                          = "iamPolicyCloudTrailS3Access"
  description                   = "S3 access policy for cloudtrail"

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
              "Resource": "cloudtrail_bucket.arn",
              "Sid": ""
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "DescribeAccess-attach" {
  role                        = aws_iam_role.iamRole.name
  policy_arn                  = aws_iam_policy.iamPolicyDescribeAccess.arn
}

resource "aws_iam_role_policy_attachment" "CloudTrailS3Access-attach" {
count                         = var.EnableNewCloudTrail ? 1 : 0
  role                      = aws_iam_role.iamRole.name
  policy_arn                = aws_iam_policy.iamPolicyCloudTrailS3Access[count.index].arn
}
