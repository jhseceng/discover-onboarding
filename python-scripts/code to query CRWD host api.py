

# Create the host filter
#
# platform_name options include 'Linux' and 'Windows'
#
host_query_filter = "platform_name: 'Linux' + instance_id: '" + instance['AWS InstanceId'] + "'"

# Query the falcon API to fetch the aid.
# Once you have the aid other api operations are possible
falcon_aid = query_falcon_host(auth_header, host_query_filter)


def query_falcon_host(_auth_header, _host_filter):
    _url = "https://api.crowdstrike.com/devices/queries/devices/v1"
    _PARAMS = {"offset": 0,
               "limit": 10,
               "filter": _host_filter
               }
    _headers = {
        "Authorization": _auth_header
    }

    _response = requests.request("GET", _url, headers=_headers, params=_PARAMS)

    _json_obj = json.loads(_response.text.encode('utf8'))
    if len(_json_obj['resources']) != 0:
        return _json_obj['resources'][0]
    else:
        return

#
# Usting systems manager parameter store to store API keys used to Oauth2 token
# In this case Falcon_ClientID and Falcon_Secret
# Alternative is to use secrets manager
#

def get_ssm_secure_string(parameter_name):
    ssm = boto3.client("ssm", region_name=region)
    return ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=True
    )

#
# Get the Oauth2 token for CRWD api calls
#
def get_auth_token():
    try:
        _client_id = get_ssm_secure_string('Falcon_ClientID')['Parameter']['Value']
        _client_secret = get_ssm_secure_string('Falcon_Secret')['Parameter']['Value']
        url = "https://api.crowdstrike.com/oauth2/token"

        payload = 'client_secret='+_client_secret+'&client_id='+_client_id
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
            }

        response = requests.request("POST", url, headers=headers, data=payload)
        if response.ok:
            _response_object = (response.json())
            _token = _response_object.get('access_token', '')
            if _token:
                return _token
            else:
                return
    except Exception as e:
        logger.info('Got Exception {} getting auth token'.format(e))
        return
