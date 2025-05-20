pipeline {
  agent {
    kubernetes {
      defaultContainer 'kaniko'
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
          containers:
            - name: kaniko
              image: gcr.io/kaniko-project/executor:latest
              imagePullPolicy: Always
              tty: true
              volumeMounts:
                - name: docker-config
                  mountPath: /kaniko/.docker

          volumes:
            - name: docker-config
              secret:
                secretName: regcred
                items:
                  - key: .dockerconfigjson
                    path: config.json
      """
    }
  }

  environment {
    IMAGE_TAG = ""
    AUTH_REPO = ""
    ADMIN_REPO = ""
    USER_REPO = ""
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        script {
          IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }

        withCredentials([string(credentialsId: 'reposity-base', variable: 'REGISTRY_BASE')]) {
          script {
            AUTH_REPO = "${REGISTRY_BASE}/eks-auth-demo"
            ADMIN_REPO = "${REGISTRY_BASE}/eks-admin-demo"
            USER_REPO = "${REGISTRY_BASE}/eks-user-demo"
          }
        }

        withCredentials([file(credentialsId: 'env-file', variable: 'ENV_FILE')]) {
          sh '''
            echo "Loading env file"
            cp $ENV_FILE .env
            cat .env
          '''
        }
      }
    }

    stage('Build and Push Images') {
      parallel {
        stage('Auth') {
          steps {
            container('kaniko') {
              sh """
                /kaniko/executor \
                  --context=${WORKSPACE} \
                  --dockerfile=${WORKSPACE}/apps/auth/Dockerfile \
                  --destination=${AUTH_REPO}:${IMAGE_TAG} \
                  --build-arg-file .env \
                  --verbosity=info
              """
            }
          }
        }

        stage('Admin') {
          steps {
            container('kaniko') {
              sh """
                /kaniko/executor \
                  --context=${WORKSPACE} \
                  --dockerfile=${WORKSPACE}/apps/admin/Dockerfile \
                  --destination=${ADMIN_REPO}:${IMAGE_TAG} \
                  --build-arg-file .env \
                  --verbosity=info
              """
            }
          }
        }

        stage('User') {
          steps {
            container('kaniko') {
              sh """
                /kaniko/executor \
                  --context=${WORKSPACE} \
                  --dockerfile=${WORKSPACE}/apps/user/Dockerfile \
                  --destination=${USER_REPO}:${IMAGE_TAG} \
                  --build-arg-file .env \
                  --verbosity=info
              """
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "Images built and pushed successfully."
    }
    failure {
      echo "Pipeline failed."
    }
  }
}
