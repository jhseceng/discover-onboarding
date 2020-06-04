import boto3
import argparse
import logging
from logging.handlers import RotatingFileHandler
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
# handler = logging.StreamHandler()
handler = RotatingFileHandler("send_sns.log", maxBytes=20971520, backupCount=5)
formatter = logging.Formatter('%(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)



def publish_sns(topic, message, region):
    try:
        sns = boto3.client('sns', region_name = region)
        # Publish a simple message to the specified SNS topic

        response = sns.publish(
            TopicArn=topic,
            Message=message,
        )
        return response
    except Exception as e:
        logger.info("Got Exception \n {} \n Publishing message")

def format_notification_message( account_id, cloudTrailCreated, iamRole, version="1.1"):
    data = {
            "Version": version,
            "AccountID":account_id,
            "CloudTrailCreated": cloudTrailCreated,
            "IamRoleARN": iamrole
    }
    message = json.dumps({'default': json.dumps(data)})
    return message

def main(aws_region, topic, account, cloudtrailstatus, iamrole):
    message = format_notification_message(account, cloudtrailstatus, iamrole)
    message_response = publish_sns(topic,message,aws_region)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Get Params to send notification to CRWD topic')
    parser.add_argument('-r', '--aws_region', help='AWS Region', required=True)
    parser.add_argument('-t', '--topic', help='SNS Topic', required=True)
    parser.add_argument('-a', '--account', help='AWS Account', required=True)
    parser.add_argument('-c', '--cloudtrailstatus', help='Cloudtrail enabled yes/no', required=True)
    parser.add_argument('-i', '--iamrole', help='IAM Role', required=True)

    args = parser.parse_args()

    aws_region = args.aws_region
    topic = args.topic
    account = args.account
    cloudtrail_enabled = args.cloudtrailstatus
    iamrole = args.iamrole

    main(aws_region, topic, account, cloudtrail_enabled, iamrole)

# Print out the response

# json dict to send to topic:
#     "Properties": {
#         "ServiceToken": {"Ref": "SnsTopicRegistration"},
#         "Version": "1.1",
#         "AccountID": {
#             "Ref": "AWS::AccountId"
#         },
#         "CloudTrailCreated": {
#             "Ref": "EnableNewCloudTrail"
#         },
#         "IamRoleARN": {
#             "Fn::GetAtt": [
#                 "iamRole",
#                 "Arn"
#             ]
#         }
#     }