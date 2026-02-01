# AWS Lambda Function

A simple AWS Lambda function that returns a hello world message.

## Files

- `lambda_function.py` - Main Lambda function handler
- `requirements.txt` - Python dependencies (if needed)

## Local Testing

You can test the Lambda function locally:

```python
from lambda_function import lambda_handler

# Simulate an event
event = {
    "queryStringParameters": {
        "name": "World"
    }
}

context = {}
response = lambda_handler(event, context)
print(response)
```

## Deployment

### Option 1: Using AWS Console

1. Go to AWS Lambda Console
2. Create a new function
3. Choose "Author from scratch"
4. Runtime: Python 3.11 (or your preferred version)
5. Upload `lambda_function.py` directly or as a zip file

### Option 2: Using AWS CLI

```bash
# Create a deployment package
zip function.zip lambda_function.py

# Create the Lambda function
aws lambda create-function \
  --function-name hello-world-lambda \
  --runtime python3.11 \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-execution-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip

# Update the function
aws lambda update-function-code \
  --function-name hello-world-lambda \
  --zip-file fileb://function.zip
```

### Option 3: Using SAM or Serverless Framework

Create a `template.yaml` for AWS SAM or `serverless.yml` for Serverless Framework.

## Testing

Test the deployed function using AWS Console or CLI:

```bash
aws lambda invoke \
  --function-name hello-world-lambda \
  --payload '{"key": "value"}' \
  response.json

cat response.json
```

## Environment Variables

You can add environment variables in the Lambda configuration:
- AWS Console: Configuration → Environment variables
- AWS CLI: Use `--environment` flag

## Monitoring

- View logs in CloudWatch Logs
- Set up CloudWatch metrics and alarms
- Use AWS X-Ray for distributed tracing