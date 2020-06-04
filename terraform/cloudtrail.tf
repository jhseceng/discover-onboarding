
resource "aws_cloudtrail" "crwd_trail" {
  count                         = var.EnableNewCloudTrail ? 1 : 0
  name = var.CloudTrailName
  sns_topic_name                = var.SnsTopicCloudTrail
  event_selector {
    read_write_type = "WriteOnly"
    include_management_events = true
  }
  include_global_service_events = true
  enable_logging                = true
  is_multi_region_trail         = true
  s3_bucket_name                = var.CloudTrailS3BucketName
}

