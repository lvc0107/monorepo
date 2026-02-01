pipeline {
    agent {
        docker {
            image 'jenkins-kind-agent:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {

        stage('Build FastAPI Docker Image') {
            steps {
                dir('fastapi-service1') {
                    sh 'docker build -t fastapi-service1:latest .'
                }
            }
        }

        stage('Load image into kind') {
            steps {
                sh 'kind load docker-image fastapi-service1:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f fastapi-service1/k8s/deployment.yaml'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods -l app=fastapi-service1'
            }
        }
    }
}
