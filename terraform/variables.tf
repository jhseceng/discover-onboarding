variable "CSAssumingRoleName" {}
variable "RoleName" {
}
variable "ExternalID" {
}
variable "CSAccountNumber"  {
}
variable "SnsTopicRegistration" {
}
variable "SnsTopicCloudTrail" {
}
variable "EnableNewCloudTrail" {
  description = "If true, enable new cloud trail"
  type        = bool
  default = true
}
variable "CloudTrailName" {
}
variable "CloudTrailS3BucketName" {
  type = string
}
variable "CloudTrailS3LogExpiration" {
  type = number
  default = 7
}
variable "aws_region" {
  type = string
  default = "us-east-1"
}
variable "aws_local_account" {
  type=string
}