pipeline {
  agent {
    docker {
      image 'jenkins-agent-helm:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock -v ~/.kube:/root/.kube'
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

    stage('Build Docker Image') {
      steps {
        sh """
          docker build \
            -t ${IMAGE_NAME}:${IMAGE_TAG} \
            fastapi-service1
        """
      }
    }

    stage('Helm Deploy (DEV)') {
      when {
        not { branch 'main' }
      }
      steps {
        sh """
          helm upgrade --install ${SERVICE_NAME} ${CHART_PATH} \
            --set image.repository=${IMAGE_NAME} \
            --set image.tag=${IMAGE_TAG}
        """
      }
    }

    stage('Helm Deploy (MAIN)') {
      when {
        branch 'main'
      }
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
