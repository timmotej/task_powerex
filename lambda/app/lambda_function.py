import json
import re
import boto3
import os

import urllib

print("Loading function")

s3 = boto3.client("s3")
# source_bucket = os.getenv("SOURCE_BUCKET", "bucket_powerex_files_input")
target_bucket = os.getenv("TARGET_BUCKET", "bucket_powerex_files_output")
prefix = os.getenv("PREFIX", "powerex_")


# if need not to duplicate prefix
# def return_filename_with_prefix(name, prefix):
#    """
#    checks if filename and prefix is correct
#    If yes, returns filename with prefix (doesn't duplicate prefices!)
#    If no, returns False
#    """
#    pattern = r"[A-Za-z0-9_.][A-Za-z0-9_.-]*$"
#    if not (re.match(pattern,prefix) and re.match(pattern,name)):
#        return False
#    if prefix in [""] or name.startswith(prefix):
#        return name
#    else:
#        return f"{prefix}{name}"


def lambda_handler(event, context):
    print(json.dumps(event, indent=2))
    try:
        if event["Records"][0].get("test",False):
            return {
                "statusCode": 200,
                "data": "Test successful"
            }
        source_bucket = event["Records"][0]["s3"]["bucket"]["name"]
        object_key = urllib.parse.unquote_plus(
            event["Records"][0]["s3"]["object"]["key"]
        )
        copy_source = {"Bucket": source_bucket, "Key": object_key}

        print("Source bucket : ", source_bucket)
        print("Target bucket : ", target_bucket)
        print("Log Stream name: ", context.log_stream_name)
        print("Log Group name: ", context.log_group_name)
        print("Request ID: ", context.aws_request_id)
        print("Mem. limits(MB): ", context.memory_limit_in_mb)

        s3.copy_object(
            Bucket=target_bucket, Key=f"{prefix}{object_key}", CopySource=copy_source
        )
        s3.delete_object(Bucket=source_bucket, Key=object_key)
        return {
            "statusCode": 200,
            "data": {
                "target_bucket": target_bucket,
                "source_bucket": source_bucket,
                "filename": object_key,
            },
        }
    except:
        return {"statusCode": 404, "data": event}
