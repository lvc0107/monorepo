pipeline {
  agent any

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

    stage('Setup Kubeconfig') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            mkdir -p $HOME/.kube
            cp $KUBECONFIG_FILE $HOME/.kube/config
            chmod 600 $HOME/.kube/config
            
            kubectl config get-contexts
            kubectl config current-context
            kubectl cluster-info
            kubectl get nodes
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
        script {
          // Ejecutar helm en contenedor, pero montando solo lo necesario
          docker.image('jenkins-agent-helm:latest').inside('--add-host=kubernetes.docker.internal:host-gateway -v $HOME/.kube:/root/.kube:ro') {
            sh '''
              export KUBECONFIG=/root/.kube/config
              
              helm version
              helm upgrade --install ${SERVICE_NAME} ${CHART_PATH} \
                --set image.repository=${IMAGE_NAME} \
                --set image.tag=${BUILD_NUMBER}
            '''
          }
        }
      }
    }
  }

  post {
    always {
      sh '''
        rm -f $HOME/.kube/config 2>/dev/null || true
      '''
    }
    failure {
      echo "❌ Deployment failed"
    }
    success {
      echo "✅ Deployment successful"
    }
  }
}