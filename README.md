Monorepo - Multi-Project Repository
This monorepo contains three independent Python projects:

Projects
1. FastAPI Service (/fastapi-service)
A simple FastAPI application with a hello world endpoint.
Run locally:
bashcd fastapi-service
pip install -r requirements.txt
uvicorn main:app --reload
Visit: http://localhost:8000

2. AWS Lambda (/aws-lambda)
A serverless Python function for AWS Lambda.
Deploy:
bashcd aws-lambda
zip function.zip lambda_function.py
# Upload function.zip to AWS Lambda

3. Kubernetes CronJob (/k8s-cronjob)
A Python script designed to run as a Kubernetes CronJob.
Deploy:
bashcd k8s-cronjob
docker build -t your-registry/k8s-cronjob:latest .
docker push your-registry/k8s-cronjob:latest
kubectl apply -f cronjob.yaml


./.gitignore
./QUICKSTART.MD
./README.md
./aws-lambda1/README.md
./aws-lambda1/lambda_functions.py
./aws-lambda1/requirements.txt
./aws-lambda2/README.md
./aws-lambda2/lambda_functions.py
./aws-lambda2/requirements.txt
./fastapi-service1/README.md
./fastapi-service1/main.py
./fastapi-service1/requirements.txt
./fastapi-service2/README.md
./fastapi-service2/main.py
./fastapi-service2/requirements.txt
./k8s-cronjob1/Dokerfile
./k8s-cronjob1/README.md
./k8s-cronjob1/app.py
./k8s-cronjob1/cronjob.yaml
./k8s-cronjob1/requirements.txt
./k8s-cronjob2/Dokerfile
./k8s-cronjob2/README.md
./k8s-cronjob2/app.py
./k8s-cronjob2/cronjob.yaml
./k8s-cronjob2/requirements.txt

Repository Structure:
```
tree .
monorepo
├── QUICKSTART.MD
├── README.md
├── aws-lambda1
│   ├── README.md
│   ├── lambda_functions.py
│   └── requirements.txt
├── aws-lambda2
│   ├── README.md
│   ├── lambda_functions.py
│   └── requirements.txt
├── fastapi-service1
│   ├── README.md
│   ├── main.py
│   └── requirements.txt
├── fastapi-service2
│   ├── README.md
│   ├── main.py
│   └── requirements.txt
├── k8s-cronjob1
│   ├── Dokerfile
│   ├── README.md
│   ├── app.py
│   ├── cronjob.yaml
│   └── requirements.txt
└── k8s-cronjob2
    ├── Dokerfile
    ├── README.md
    ├── app.py
    ├── cronjob.yaml
    └── requirements.txt

7 directories, 24 files
```


CI/CD strategy
```

                         ┌────────────────────┐
                         │   GitHub           │
                         │   (monorepo)       │
                         └─────────┬──────────┘
                                   │
                              PR / merge
                                   │
                         ┌─────────▼──────────┐
                         │ Jenkins Controller │
                         │ (orchestrator)     │
                         └─────────┬──────────┘
                                   │
                         Detect changed paths
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ AWS Lambdas    │       │ FastAPI Services  │       │ K8s CronJobs    │
│ (aws-lambda*)  │       │ (fastapi-*)       │       │ (k8s-cronjob*)  │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Build & Test   │       │ Build & Test      │       │ Build Job Image  │
│ (SAM / Pytest) │       │ (Docker)           │       │ (Docker)        │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Package Zip    │       │ Build Image       │       │ Push Image      │
│ (artifact)     │       │ (FastAPI)          │       │ (registry)     │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Upload to S3   │       │ Push Image        │       │ kubectl apply   │
│ (versioned)    │       │ (ECR / registry)  │       │ (CronJob)       │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Deploy Lambda  │       │ kubectl deploy    │       │ Runtime schedule│
│ (AWS API)     │       │ (Deployment)      │       │ (K8s)           │
└────────────────┘       └───────────────────┘       └──────────────────┘

```

Paralellims in CI

```

                ┌──────────────┐
                │ Git Merge    │
                │ (main)       │
                └──────┬───────┘
                       │
               Detect changes
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼─────────┐
│ Lambda A        │          │ Lambda B          │
│ changed?        │          │ changed?          │
└───────┬────────┘          └─────────┬─────────┘
        │ yes                         │ no
        │                             │
┌───────▼────────┐          ┌──────────▼─────────┐
│ Build & Test   │          │ Skip build         │
│ Lambda A       │          │ Use existing       │
└───────┬────────┘          │ artifact           │
        │                   └──────────┬─────────┘
        │                              │
┌───────▼────────┐          ┌──────────▼─────────┐
│ Package        │          │ Fetch artifact     │
│ (zip/image)    │          │ (S3 / registry)    │
└───────┬────────┘          └──────────┬─────────┘
        │                              │
        └──────────────┬───────────────┘
                       │
               Update lock file
                       │
               Compare with deployed
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼─────────┐
│ Deploy Lambda A│          │ Deploy Lambda B   │
│ (independent)  │          │ (independent)     │
└───────┬────────┘          └─────────┬─────────┘
        │                             │
        └──────────────┬──────────────┘
                       │
                Post-deploy checks
                       │
                    Done
```


This diagram represents the logical delivery flow.
Infrastructure choices only decide where each box executes.

K8
```
                    ┌────────────────────┐
                    │ Jenkins Controller │
                    └─────────┬──────────┘
                              │ requests agent
                    ┌─────────▼──────────┐
                    │ Kubernetes Cluster │
                    └─────────┬──────────┘
                              │
                  ┌───────────▼───────────┐
                  │ Ephemeral Jenkins Pod  │
                  │ (build / deploy task) │
                  └───────────┬───────────┘
                              │
                          Executes
                              │
                         ┌────▼────┐
                         │  Step   │
                         └─────────┘


```


| Property              | Complies |
| --------------------- | -------- |
| Independent builds    | ✅       |
| Isolated deploys      | ✅       |
| Parallelism           | ✅       |
| Reproducibility       | ✅       |
| Scalability           | ✅       |
| Dev / Ops separation  | ✅       |

Jenkins (locally just for PoC)
```

docker run -d \
  --name jenkins-local \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  jenkins/jenkins:lts

```
MAY FAIL because it doesn't know how to use the docker CLI provided by the host
note that if we must reinstall we must also delete the volume
It's a PoC, we're playing

docker stop jenkins-local
docker rm jenkins-local
docker volume rm jenkins_home

jenkins-local
jenkins-local
jenkins_home


Using Docker compose it fixes
```
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins-local
    restart: unless-stopped
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker                  # here we can use the host docker CLI
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock

volumes:
  jenkins_home:

```

GET the first Admin Password
docker exec jenkins-local \
  cat /var/jenkins_home/secrets/initialAdminPassword



🔍 What exactly does this command enable

| Feature                                    | Enabled                  |
| ------------------------------------------ | ------------------------- |
| UI Jenkins                                 | ✅ `http://localhost:8080` |
| Pipelines declarativos                     | ✅                         |
| Docker agents (`agent { docker { ... } }`) | ✅                         |
| Contenedores por stage                     | ✅                         |
| Builds paralelos                           | ✅                         |
| Monorepo pipelines                         | ✅                         |
| SAM / kubectl vía imágenes                 | ✅                         |


🔐 Get initial password




TEST 1

pipeline {
  agent any
  stages {
    stage('Docker test') {
      steps {
        sh 'docker version'
      }
    }
  }
}
