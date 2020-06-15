# Falcon Discover for Cloud - Account Onboarding
A collection of templates, scripts and documentation to setup AWS accounts in Falcon Discover.
### Folder Structure

1. Documents - Documentation
 
2. Templates 
  * Terraform
    1. Template for Master (log archive account) 
    2. Template for Additional accounts
  * CFT 
    1. Template for Master (log archive account) 
    2. Template for Additional accounts
  

## Terraform Notes
Each directory contains a .tf, .tfvars and .vars file.   

The directory also contains a register_account.py file that can be run either as a `local-exec` provisioner 
or as a standalone script.  Once the resources have been created in the account it has to be registered with the
Crowdstrike API. The format of the request is 
```python
{
  "resources":[
    {
      "cloudtrail_bucket_owner_id":"string",
      "cloudtrail_bucket_region":"string",
      "external_id":"string",
      "iam_role_arn":"string",
      "id":"string",
      "rate_limit_reqs":0,
      "rate_limit_time":0
    }
  ]
}
```



  - cloudtrail_bucket_owner_id string The 12 digit AWS account which is hosting the S3 bucket containing cloudtrail logs 
  - cloudtrail_bucket_region string Region where the S3 bucket containing cloudtrail logs resides.
  - external_id	string ID assigned for use with cross account IAM role access.
  - iam_role_arn	string The full arn of the IAM role created in this account to control access.
  - id	string 12 digit AWS provided unique identifier for the account.
  - rate_limit_reqs	integer($integer) Rate limiting setting to control the maximum number of requests that can be made within the rate_limit_time threshold.
  - rate_limit_time	integer($int64) Rate limiting setting to control the number of seconds for which rate_limit_reqs applies.