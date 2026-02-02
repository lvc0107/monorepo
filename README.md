# Monorepo - Multi-Project Repository (PoC)
This monorepo contains three independent Python projects:

Projects
1. FastAPI Service (/fastapi-service)
A simple FastAPI application with a hello world endpoint.

- bashcd fastapi-service
- pip install -r requirements.txt
- uvicorn main:app --reload
- Visit: http://localhost:8000

2. AWS Lambda (/aws-lambda)
A serverless Python function for AWS Lambda.
Deploy:
- bashcd aws-lambda
- zip function.zip lambda_function.py.
- Upload function.zip to AWS Lambda

3. Kubernetes CronJob (/k8s-cronjob)
A Python script designed to run as a Kubernetes CronJob.
Deploy:
- bashcd k8s-cronjob
- docker build -t your-registry/k8s-cronjob:latest .
- docker push your-registry/k8s-cronjob:latest
- kubectl apply -f cronjob.yaml




### Inital Repository Structure:
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
│ Build & Test   │       │ Build & Test      │       │ Build Job Image │
│ (SAM / Pytest) │       │ (Docker)          │       │ (Docker)        │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Package Zip    │       │ Build Image       │       │ Push Image      │
│ (artifact)     │       │ (FastAPI)         │       │ (registry)      │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Upload to S3   │       │ Push Image        │       │ kubectl apply   │
│ (versioned)    │       │ (ECR / registry)  │       │ (CronJob)       │
└───────┬────────┘       └─────────┬─────────┘       └────────┬────────┘
        │                          │                          │
┌───────▼────────┐       ┌─────────▼─────────┐       ┌────────▼────────┐
│ Deploy Lambda  │       │ kubectl deploy    │       │ Runtime schedule│
│ (AWS API)      │       │ (Deployment)      │       │ (K8s)           │
└────────────────┘       └───────────────────┘       └─────────────────┘

```

Parallelism in CI

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
│ Lambda A       │          │ Lambda B          │
│ changed?       │          │ changed?          │
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

K8s
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
| Declarative pipelines                     | ✅                         |
| Docker agents (`agent { docker { ... } }`) | ✅                         |
| Containers per stage                     | ✅                         |
| Parallel builds                           | ✅                         |
| Monorepo pipelines                         | ✅                         |
| SAM / kubectl via images                 | ✅                         |


🔐 Get initial password




### Pipeline TEST 1
```
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
```



HELM

Lets create a docker image for hosting the jenkins agent in charge to deploy the fast api microservice

1) Create charts folder (THI must be on its own repo (a config repo))
2) create jenkins_agent folder (this is here just as PoC. in a real project we must no mixs the 
product code with the insfrasture code)
3) Create Dockerfile
4) ```docker build -t jenkins-agent-helm:latest``` . (Not need to upload to a registry (PoC))
5) Using Docker Destop. Enable Kubernetes. We are gonna create a cluster locally using  and conencting with the same docker deamon.
6) Create a running container for teh agent. 
```
docker run -d \                   
  --name jenkins-agent \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube \
  jenkins-agent-helm:latest
  ```

7) Verify the Jenkins controller and the Jenkis agent are running.
```
docker ps | grep jenkins 

254acdd63565   jenkins-agent-helm:latest   "tail -f /dev/null"      3 minutes ago        Up 3 minutes                                                           jenkins-agent
e4a8b59a81e3   jenkins/jenkins:lts         "/usr/bin/tini -- /u…"   22 hours ago         Up 27 minutes       0.0.0.0:8080->8080/tcp, 0.0.0.0:50000->50000/tcp   jenkins
```
8) in Jenkins Create credentials for k8 cluster
 8.1) cat kube_config >> kube_config(in host)
 8.2) In Jenkins → Manage Jenkins → Credentials
Scope: Global
Kind: Secret file
File: paste kube_config file
ID: kubeconfig-docker-desktop
📌 This is simulating exactly:
- EKS kubeconfig
- GKE kubeconfig
- AKS kubeconfig