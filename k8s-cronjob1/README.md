# Kubernetes CronJob

A Python application designed to run as a Kubernetes CronJob.

## Files

- `app.py` - Main Python application
- `Dockerfile` - Container image definition
- `cronjob.yaml` - Kubernetes CronJob manifest
- `requirements.txt` - Python dependencies

## Building the Docker Image

```bash
# Build the image
docker build -t your-registry/k8s-cronjob:latest .

# Test locally
docker run --rm your-registry/k8s-cronjob:latest

# Push to registry
docker push your-registry/k8s-cronjob:latest
```

## Deploying to Kubernetes

1. Update the image name in `cronjob.yaml`:
   ```yaml
   image: your-registry/k8s-cronjob:latest
   ```

2. Update the schedule in `cronjob.yaml`:
   ```yaml
   schedule: "0 0 * * *"  # Cron format
   ```

3. Apply the CronJob:
   ```bash
   kubectl apply -f cronjob.yaml
   ```

## Managing the CronJob

### View CronJobs
```bash
kubectl get cronjobs
```

### View Jobs created by CronJob
```bash
kubectl get jobs --selector=app=hello-world-cronjob
```

### View Pods
```bash
kubectl get pods --selector=app=hello-world-cronjob
```

### View Logs
```bash
# Get the latest pod name
POD_NAME=$(kubectl get pods --selector=app=hello-world-cronjob --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')

# View logs
kubectl logs $POD_NAME
```

### Manually Trigger a Job
```bash
kubectl create job --from=cronjob/hello-world-cronjob manual-job-001
```

### Delete the CronJob
```bash
kubectl delete cronjob hello-world-cronjob
```

## Cron Schedule Format

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
│ │ │ │ │
* * * * *
```

### Common Schedules

- `"*/5 * * * *"` - Every 5 minutes
- `"0 * * * *"` - Every hour
- `"0 0 * * *"` - Every day at midnight
- `"0 0 * * 0"` - Every Sunday at midnight
- `"0 9 * * 1-5"` - 9 AM on weekdays
- `"0 0 1 * *"` - First day of every month at midnight

## Configuration Options

### Concurrency Policy
- `Allow` - Allows concurrent jobs
- `Forbid` - Prevents concurrent jobs (skips new run if previous still running)
- `Replace` - Replaces currently running job with a new one

### Job History
- `successfulJobsHistoryLimit` - Number of successful jobs to keep
- `failedJobsHistoryLimit` - Number of failed jobs to keep

### Suspend
To temporarily disable the CronJob:
```bash
kubectl patch cronjob hello-world-cronjob -p '{"spec":{"suspend":true}}'
```

To resume:
```bash
kubectl patch cronjob hello-world-cronjob -p '{"spec":{"suspend":false}}'
```

## Monitoring

Add monitoring and alerting:
- Check job success/failure rates
- Monitor execution duration
- Alert on consecutive failures
- Track resource usage

## Security Considerations

- Use non-root user in container
- Set resource limits
- Use private registry with image pull secrets
- Apply appropriate RBAC policies
- Use secrets for sensitive data
