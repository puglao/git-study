import json

def lambda_handler(event, context):
    # TODO implement
    print(context)
    return {
        'statusCode': 200,
        'body': event
    }
