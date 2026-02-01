import json


def lambda_handler(event, context):
    """
    AWS Lambda function handler
    
    Args:
        event: Event data passed to the function
        context: Runtime information about the Lambda function
        
    Returns:
        dict: Response with statusCode and body
    """
    
    print("Hello World from AWS Lambda!")
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': 'Hello World from AWS Lambda!',
            'event': event
        })
    }
