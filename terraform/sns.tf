resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = var.SnsTopicRegistration
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:us-west-2:432981146916:terraform-queue-too"
}

variable "sqs" {
  default = {
    account-id = var.aws_local_account
    role-name  = aws_iam_role.iamRole.name
    name       = "example-sqs-queue"
    region     = var.aws_region
  }
}