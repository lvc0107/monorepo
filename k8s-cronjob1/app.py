#!/usr/bin/env python3
"""
Kubernetes CronJob Application
Simple hello world script that runs on a schedule
"""

import os
from datetime import datetime


def main():
    """Main function that executes the cron job task"""
    
    timestamp = datetime.now().isoformat()
    job_name = os.getenv('JOB_NAME', 'k8s-cronjob')
    
    print(f"[{timestamp}] Hello World from Kubernetes CronJob!")
    print(f"Job Name: {job_name}")
    print(f"Execution completed successfully")
    
    # Add your actual job logic here
    # For example:
    # - Database cleanup
    # - Data synchronization
    # - Report generation
    # - Health checks
    # etc.


if __name__ == "__main__":
    main()
