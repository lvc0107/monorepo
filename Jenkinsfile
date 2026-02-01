pipeline {
  agent any

  stages {

    stage('CI - Feature / PR') {
      when {
        expression { env.CHANGE_ID != null }
      }
      steps {
        echo "🧪 CI para Pull Request #${env.CHANGE_ID}"
        echo "Branch: ${env.BRANCH_NAME}"
        sh 'echo correr tests DEV'
        }
    }


    stage('CD - Main') {
      when {
        branch 'main'
      }
      steps {
        echo "🚀 Deploy a PROD"
      }
    }
  }
}
