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
    CHART_PATH   = 'fastapi-service1/charts/fastapi-service1'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Kubernetes Context') {
      steps {
        sh '''
          mkdir -p /root/.kube
          kubectl config set-cluster docker-desktop --server=https://host.docker.internal:6443 --insecure-skip-tls-verify=true || true
          kubectl config set-credentials docker-desktop --username=docker --password=docker || true
          kubectl config set-context docker-desktop --cluster=docker-desktop --user=docker-desktop || true
          kubectl config use-context docker-desktop
          kubectl cluster-info
          kubectl get nodes
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build \
            -t ${IMAGE_NAME}:${IMAGE_TAG} \
            fastapi-service1
        """
      }
    }

    stage('Helm Deploy') {
      steps {
        sh """
          helm upgrade --install ${SERVICE_NAME} ${CHART_PATH} \
            -f ${CHART_PATH}/values-prod.yaml \
            --set image.repository=${IMAGE_NAME} \
            --set image.tag=${IMAGE_TAG}
        """
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
