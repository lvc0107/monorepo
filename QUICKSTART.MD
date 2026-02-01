# Quick Start Guide

## Prerequisites

- Python 3.11+
- Docker (for K8s CronJob)
- Kubernetes cluster (for K8s CronJob)
- AWS Account (for Lambda)

## 1. FastAPI Service

```bash
cd fastapi-service
pip install -r requirements.txt
uvicorn main:app --reload
```

Visit http://localhost:8000 to see the hello world message.

## 2. AWS Lambda

### Local Test
```python
python3 << EOF
from aws_lambda.lambda_function import lambda_handler
print(lambda_handler({}, {}))
EOF
```

### Deploy to AWS
```bash
cd aws-lambda
zip function.zip lambda_function.py
# Upload to AWS Lambda Console or use AWS CLI
```

## 3. Kubernetes CronJob

### Build and Test Locally
```bash
cd k8s-cronjob
docker build -t k8s-cronjob:latest .
docker run --rm k8s-cronjob:latest
```

### Deploy to Kubernetes
```bash
# Update image name in cronjob.yaml first
kubectl apply -f cronjob.yaml
kubectl get cronjobs
```

## Next Steps

- Customize each project for your needs
- Add proper error handling
- Implement logging
- Add tests
- Set up CI/CD pipelines
