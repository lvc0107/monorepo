pipeline {
  agent {
    label 'jenkins-agent-helm'
  }

  environment {
    SERVICE_NAME = 'fastapi-service1'
    IMAGE_NAME   = 'fastapi-service1'
    IMAGE_TAG    = "${env.BUILD_NUMBER}"
    CHART_PATH   = 'charts/fastapi-service1'
    NAMESPACE    = 'monorepo'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Kubeconfig') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            mkdir -p /tmp
            cp $KUBECONFIG_FILE /tmp/kubeconfig
            chmod 600 /tmp/kubeconfig
            
            sed -i 's/127.0.0.1/kubernetes.docker.internal/g' /tmp/kubeconfig
            sed -i 's/localhost/kubernetes.docker.internal/g' /tmp/kubeconfig
            
            export KUBECONFIG=/tmp/kubeconfig
            kubectl config get-contexts
            kubectl cluster-info
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build \
            -t ${IMAGE_NAME}:${BUILD_NUMBER} \
            -t ${IMAGE_NAME}:latest \
            ${SERVICE_NAME}
        '''
      }
    }

    stage('Helm Deploy') {
      steps {
        sh '''
          export KUBECONFIG=/tmp/kubeconfig
          
          helm upgrade --install ${SERVICE_NAME} ${CHART_PATH} \
            --namespace ${NAMESPACE} \
            --create-namespace \
            --set image.repository=${IMAGE_NAME} \
            --set image.tag=${BUILD_NUMBER} \
            --wait \
            --timeout 5m
        '''
      }
    }

    stage('Verify Deployment') {
      steps {
        sh '''
          export KUBECONFIG=/tmp/kubeconfig
          
          echo "=== Namespace: ${NAMESPACE} ==="
          kubectl get pods -n ${NAMESPACE} -l app=${SERVICE_NAME}
          kubectl get svc -n ${NAMESPACE} ${SERVICE_NAME}
        '''
      }
    }
  }

  post {
    failure {
      echo "❌ Deployment failed"
    }
    success {
      echo "✅ Deployment successful in namespace: ${NAMESPACE}"
    }
  }
}