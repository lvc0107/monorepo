pipeline {
  agent {
    docker {
      image 'jenkins-agent-helm:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    SERVICE_NAME = 'fastapi-service1'
    IMAGE_NAME   = 'fastapi-service1'
    IMAGE_TAG    = "${env.BUILD_NUMBER}"
    CHART_PATH   = 'charts/fastapi-service1'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Kubernetes Context') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-docker-desktop', variable: 'KUBECONFIG')]) {
          sh '''
            export KUBECONFIG=$KUBECONFIG
            kubectl config get-contexts
            kubectl config use-context docker-desktop
            kubectl get nodes
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t fastapi-service1:${BUILD_NUMBER} fastapi-service1'
      }
    }

    stage('Helm Deploy') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-docker-desktop', variable: 'KUBECONFIG')]) {
          sh '''
            export KUBECONFIG=$KUBECONFIG
            helm upgrade --install fastapi-service1 ${CHART_PATH} \
              --set image.repository=fastapi-service1 \
              --set image.tag=${BUILD_NUMBER}
          '''
        }
      }
    }
  }
    post {
    failure {
      echo "❌ Deployment failed"
    }
    success {
      echo "✅ Deployment successful"
    }
  }
}
