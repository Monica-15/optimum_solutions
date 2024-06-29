import json
import boto3
import os
from datetime import datetime, timedelta

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    sns = boto3.client('sns')
    bucket_names = json.loads(os.getenv('BUCKET_NAMES'))
    alert_topic_arn = os.getenv('ALERT_TOPIC_ARN')
    
    missing_files = []

    for bucket in bucket_names:
        response = s3.list_objects_v2(Bucket=bucket)
        if 'Contents' not in response:
            missing_files.append(bucket)
        else:
            # Check if any file uploaded in the last 24 hours
            latest_upload = max(obj['LastModified'] for obj in response['Contents'])
            if latest_upload < datetime.now(tz=latest_upload.tzinfo) - timedelta(days=1):
                missing_files.append(bucket)
    
    if missing_files:
        message = f"No files uploaded in the last 24 hours for buckets: {', '.join(missing_files)}"
        sns.publish(TopicArn=alert_topic_arn, Message=message, Subject='Missing Files Alert')

    return {
        'statusCode': 200,
        'body': json.dumps('Check complete')
    }
