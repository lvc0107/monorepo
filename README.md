# Monorepo - Multi-Project Repository (PoC)
This monorepo contains three independent Python projects:

Projects
1. FastAPI Service (/fastapi-service)
A simple FastAPI application with a hello world endpoint.

- bashcd fastapi-service  # TODO CHECK
- pip install -r requirements.txt
- uvicorn main:app --reload
- Visit: http://localhost:1111 or http://localhost:2222

2. AWS Lambda (/aws-lambda)
A serverless Python function for AWS Lambda.
Deploy:
- bashcd aws-lambda
- zip function.zip lambda_function.py.
- Upload function.zip to AWS Lambda

3. Kubernetes CronJob (/k8s-cronjob)
A Python script designed to run as a Kubernetes CronJob.
Deploy:
- bashcd k8s-cronjob  # TODO CHECK
- docker build -t your-registry/k8s-cronjob:latest .
- docker push your-registry/k8s-cronjob:latest # NOT YET
- kubectl apply -f cronjob.yaml #USING HELM




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
                    ┌────────────────────┐
                    │ Jenkins Agent      │
                    └─────────┬──────────┘
                              │
                    ┌─────────▼──────────┐
                    │ Kubernetes Cluster │
                    └─────────┬──────────┘
                              │
                  ┌───────────▼───────────┐
                  │ Ephemeral Jenkins Pod │
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


# SETUP 

1. Jenkins (locally just for PoC) . In second Roud we will move it to some cloud provider.

Using Docker compose:
```
# Execute inside jenkins_local folder
docker compose down
docker compose up -d

#check the container status

docker logs -f jenkins-controller

touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?


# Check the volume permissions. If you see something like this, it means that the Jenkins container does not have the correct permissions to write to the volume. This is a common issue when using Docker volumes with Jenkins, as Jenkins needs to write to its home directory for configuration and job data.

# Check current volumes
docker volume ls | grep jenkins

local     jenkins_home
local     jenkins_local_jenkins_home


# fix: Create new container with the same volume and change the permissions to 1000:1000 (the user that Jenkins runs as inside the container)

docker compose down

docker run --rm \
  -v jenkins_local_jenkins_home:/var/jenkins_home \
  busybox \
  sh -c "chown -R 1000:1000 /var/jenkins_home"



[+] up 2/2
 ✔ Network jenkins-ci-net       Created                                                                                                                    0.0s
 ✔ Container jenkins-controller Created


# check the logs again to see if the permissions issue is resolved. You should see something like this, which indicates that Jenkins is starting up correctly and can write to its home directory: ou have to see: *Jenkins is fully up and running*

docker logs -f jenkins-controller


# Check the Volumes again to confirm the permissions are correct. You should see that the volume is now owned by the user with UID 1000, which is the default Jenkins user inside the container.
docker volume ls | grep jenkins

local     jenkins_local_jenkins_home

# Check the Networking
docker inspect jenkins-controller --format '{{json .NetworkSettings.Networks}}'

{"jenkins-ci-net":{"IPAMConfig":null,"Links":null,"Aliases":["jenkins-controller","jenkins"],"DriverOpts":null,"GwPriority":0,"NetworkID":"7c1c5b928745dec4eed4fb0b1315b8259f3d8c7fd11f222d1aba2a9f65835f03","EndpointID":"","Gateway":"","IPAddress":"","MacAddress":"","IPPrefixLen":0,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"DNSNames":["jenkins-controller","jenkins","0a5cbd80a3b7"]}}





# Get the first Admin Password
docker exec jenkins-controller \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

🔍 What exactly does this command enable

| Feature                                    | Enabled                    |
| ------------------------------------------ | -------------------------- |
| UI Jenkins                                 | ✅ `http://localhost:8080` |
| Declarative pipelines                      | ✅                         |
| Docker agents (`agent { docker { ... } }`) | ✅                         |
| Containers per stage                       | ✅                         |
| Parallel builds                            | ✅                         |
| Monorepo pipelines                         | ✅                         |
| SAM / kubectl via images                   | ✅                         |



2. SET JENKINS DASHBOARD 

  2.1) Change admin password  
  2.2) Install dependencies  
  2.3) Go plugins and install:  
  2.3.1) Go Manage Jenkins → Manage Plugins → Available.  
       Install Docker.  
       Install Docker Pipeline.  
       Install github-scm-trait-notification-context # for detecting PR.  
  2.3.2) Install y restart Jenkins.    
  2.4) Create multibranch pipeline.  
    2.4.1) Branch Sources: GitHub.  
  2.5) Set Github Credentials.  
  2.5.1) Create PAT in Github.  
  2.5.2) Go Jenkins → Manage Jenkins → Credentials    
      Scope: Global.  
      Kind: Secret Text.  
      Secret: <GITHUB_TOKEN>    
      ID: github-token.  
  2.5.3) Go Manage Jenkins → Credentials → System → Global credentials →  Add Credentials. 
      Kind: Username with password.  
      Username: your GitHub user.  
      Password: <GITHUB_TOKEN>.  
      ID: github-credentials.  
      Description: GitHub PAT.  
  2.5.4) Link GitHub to Jenkins.  
      Go Jenkins → Manage Jenkins → Configure System.  
      Search GitHub.  
      Add GitHub Server.  
      API URL: https://api.github.com.  
      Credentials → choose github-token.   
      ✔️ Test connection.  
  2.5.5) Go to Multibranch Pipeline → Configure.  
      In Branch Sources → GitHub:   
      Credentials → github-credentials.  
      Save.  
  2.6. Detect PR.  
    2.6.1) In Multibranch Pipeline → Branch Sources → GitHub:   
        Add these behaviours:   
      ✔ Discover branches.  
      ✔ Discover pull requests from origin. Strategy: both (so far).  
    2.6.2) In GitHub:     
      Settings → Branch protection rules.  
      Create rule for main.  
      Activar:   
      ✔ Require status checks to pass.  
      ✔ Jenkins / cicd-lab.  
      ✔ Require branches to be up to date.  
      ✔ (optional) Require PR review.  
  2.7) Create Node for agent
    2.7.1) Go Manage Jenkins → Manage Nodes and Clouds → New Node.  
      Node name: jenkins-agent-helm.  
      Type: Permanent Agent.  
      Remote root directory: /home/jenkins.  
      Labels: helm,docker,kubectl.  
      Usage: Use this node as much as possible.  
      Launch method: Launch agent by connecting it to the controller.  
      Save.



3. SET JENKINS AGENT

Lets create a docker image for hosting the jenkins agent in charge to deploy the fast api microservice

3.1) Create charts folder (This must be on its own repo (a config repo))
3.2) create jenkins_agent folder (this is here just as PoC. in a real project we must no mixs the 
product code with the infrastructure code)
3.3) Create Jenkins agent base on Dockerfile. This image will be used to run the Jenkins agent that will execute the deployment tasks. It includes Docker CLI, kubectl, and helm.
```
cd jenkins_agent
docker build -t jenkins-agent-helm:latest
``` 
(Not need to upload to a registry yet(PoC)).  
3.4) Create a running container for the agent. 


3.4.1) First validate the Network 
```
 docker ps --format "table {{.Names}}\t{{.Networks}}"

NAMES                NETWORKS
jenkins-controller   jenkins-ci-net
kind-control-plane   kind
```

3.4.2) Create the agent

```
docker rm -f jenkins-agent-helm 2>/dev/null || true
docker run -d \
  --name jenkins-agent-helm \
  --restart unless-stopped \
  --network jenkins-ci-net \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube \
  jenkins-agent-helm:latest \
  sh -c '
    set -e
    mkdir -p /home/jenkins
    curl -fsSL http://jenkins-controller:8080/jnlpJars/agent.jar -o /home/jenkins/agent.jar
    exec java -jar /home/jenkins/agent.jar \
      -url http://jenkins-controller:8080/ \
      -secret f380c3285607f406459f44523b40f7cef62ce3f036abe23925282981640e1815 \
      -name "jenkins-agent-helm" \
      -webSocket \
      -workDir "/home/jenkins"
  '


Here we are installing and using JNLP

```
Jenkins Controller (jenkins-local)
        |
        |  JNLP (50000)
        v
Docker Agent (jenkins-agent-helm)
        |
        +-- docker CLI (host socket)
        +-- kubectl (docker-desktop context)
        +-- helm
```


3.4.3) Verify connection. This command verify the connection between the controller and the agent
```
docker logs -f jenkins-agent-helm
INFO: Agent discovery successful
  Agent address: jenkins-local
  Agent port:    50000
  Identity:      98:b6:71:b0:6d:ea:52:aa:90:7b:82:31:b0:9f:19:33
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Handshaking
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Connecting to jenkins-local:50000
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Server reports protocol JNLP4-connect-proxy not supported, skipping
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Trying protocol: JNLP4-connect
Feb 08, 2026 6:35:03 PM org.jenkinsci.remoting.protocol.impl.BIONetworkLayer$Reader run
INFO: Waiting for ProtocolStack to start.
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Remote identity confirmed: 98:b6:71:b0:6d:ea:52:aa:90:7b:82:31:b0:9f:19:33
Feb 08, 2026 6:35:03 PM hudson.remoting.Launcher$CuiListener status
INFO: Connected
```



3.4.4) Verify the Jenkins controller and the Jenkins agent are running.
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



KIND