pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
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
    }
}
