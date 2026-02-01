pipeline {
  agent any

  stages {

    stage('PR Validation') {
      when { changeRequest() }
      steps {
        sh 'python --version'
      }
    }

    stage('Build Docker Image') {
      when { branch 'main' }
      steps {
        sh 'docker build -t fastapi-app:latest .'
      }
    }

    stage('Deploy to K8s') {
      when { branch 'main' }
      steps {
        sh 'kubectl apply -f k8s/deployment.yaml'
      }
    }
  }
}
