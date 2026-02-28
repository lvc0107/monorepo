pipeline {
  agent {
    docker {
      image 'jenkins-agent-helm:latest'
      args '''
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /root/.kube:/root/.kube:ro \
        --add-host=kubernetes.docker.internal:host-gateway
      '''
    }
  }

  environment {
    SERVICE_NAME = 'fastapi-service1'
    IMAGE_NAME   = 'fastapi-service1'
    IMAGE_TAG    = "${env.BUILD_NUMBER}"
    CHART_PATH   = 'charts/fastapi-service1'
    KUBECONFIG   = '/root/.kube/config'
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
          kubectl cluster-info
          kubectl get nodes
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker buildx build \
            --tag ${IMAGE_NAME}:${BUILD_NUMBER} \
            --load \
            ${SERVICE_NAME}
        '''
      }
    }

    stage('Helm Deploy') {
      steps {
        sh '''
          helm upgrade --install ${SERVICE_NAME} ${CHART_PATH} \
            --set image.repository=${IMAGE_NAME} \
            --set image.tag=${BUILD_NUMBER}
        '''
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
