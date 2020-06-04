import json
import os
import boto3
import requests



TERRAFORM_VARS = 'falcon_discover.tfvars'
PARAM_PREFIX = "param_"


def register_falcon_discover_account(account_number,region):
    register_url = "https://api.crowdstrike.com/cloud-connect-aws/entities/accounts/v1?mode=cloudformation"
    payload = json.dumps(
        {"resources":[{"id": account_number}]})
    auth_token = get_auth_token(region)
    auth_header = get_auth_header(auth_token)
    headers = {

        'Content-Type': 'application/json',
    }
    headers.update(auth_header)
    try:
        response = requests.request("POST", register_url, headers=headers, data=payload)
        if response.status_code == 200:
            return response
        else:
            print('Registration failed with response \n {}'.format(response['text']))
    except Exception as e:
        # logger.info('Got exception {} hiding host'.format(e))
        print('Got exception {} hiding host'.format(e))
        return


def get_ssm_secure_string(parameter_name, region):
    ssm = boto3.client("ssm", region_name=region)
    return ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=True
    )

def get_auth_header(_auth_token):
    if _auth_token:
        _auth_header = "Bearer " + _auth_token
        _headers = {
            "Authorization": _auth_header
        }
        return _headers


def get_auth_token(region):
    try:
        _client_id = get_ssm_secure_string('Falcon_ClientID',region)['Parameter']['Value']
        _client_secret = get_ssm_secure_string('Falcon_Secret',region)['Parameter']['Value']
    except Exception as e:
        print('Exception {}'.format(e))
    auth_token_url = "https://api.crowdstrike.com/oauth2/token"

    payload = 'client_secret='+_client_secret+'&client_id='+_client_id
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    response = requests.request("POST", auth_token_url, headers=headers, data=payload)
    if response.ok:
        _response_object = (response.json())
        _token = _response_object.get('access_token', '')
        if _token:
            return \
                _token
    return

def falcon_api_post(url, headers, data):
    try:
        response = requests.request("POST", url, headers=headers, data=data)

        json_obj =json.loads(response.text.encode('utf8'))
        if len(json_obj['resources']) != 0:
            return json_obj['resources'][0]
        else:
            return
    except Exception as e:
        print('Exception e{} posting to api'.format(e))



def remove_prefix(text, prefix):
    if text.startswith(prefix):
        return text[len(prefix):]
    return text

if __name__ == '__main__':
    account_number = "427239829194"
    region = "us-west-1"
    register_response = register_falcon_discover_account(account_number, region)
    if register_response:
        print('Registration failed')
    else:
        url = register_response['resources'][0]['cloudformation_url']
        print(url)

        with open(TERRAFORM_VARS, 'w+') as tf_fh:
            data = tf_fh.read()
        data = ''
        params_list = url.split('?')
        region_str = params_list[1].split('#')[0].replace('region', 'param_aws_region')

        tf_params = params_list[2].split('&')
        tf_params.append(region_str)

        for param in tf_params:
            if param.find(PARAM_PREFIX) >= 0:
                key_value_list = param.split('=')
                key = key_value_list[0]
                key = remove_prefix(key, PARAM_PREFIX)
                value = key_value_list[1]
                data += key + '=''"' + value + '"\n'
        tf_fh.close()
        with open(TERRAFORM_VARS, 'r+') as tf_fh_write:
            tf_fh_write.write(data)
        tf_fh_write.close()

