data "template_file" "s3policy" {
  template                      = file("s3bucketpolicy.json.tpl")
}



resource "aws_s3_bucket" "cloudtrail_bucket" {
  count                         = var.EnableNewCloudTrail ? 1 : 0
  bucket                        = var.CloudTrailS3BucketName
  acl                           = "bucket-owner-full-control"
  force_destroy                 = true
  policy                        = data.template_file.s3policy.rendered

  lifecycle_rule {
    id = "bucketlifecycle"
    enabled = true
    expiration {
      days = var.CloudTrailS3LogExpiration
    }
  }
}
