import json
import re
import boto3

import urllib.parse

print('Loading function')

s3 = boto3.client('s3')



def return_filename_with_prefix(name, prefix):
    """
    checks if filename and prefix is correct
    If yes, returns filename with prefix (doesn't duplicate prefices!)
    If no, returns False
    """
    pattern = r"[A-Za-z0-9_.][A-Za-z0-9_.-]*$"
    if not (re.match(pattern,prefix) and re.match(pattern,name)):
        return False
    if prefix in [""] or name.startswith(prefix):
        return name
    else:
        return f"{prefix}{name}"
    

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response['ContentType'])
        return response['ContentType']
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
    old_filename, prefix = event["filename"], event["prefix"]
    # prefix name
    new_filename = return_filename_with_prefix(old_filename,prefix)
    if new_filename:
        return {
            'statusCode': 200,
            'body': json.dumps({"new_filename": new_filename, "old_filename": old_filename, "prefix": prefix, "event": event})
        }
    else:
        return {
            'statusCode': 404,
            'body': 'Error: Filename or prefix not defined properly'
        }
