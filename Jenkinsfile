pipeline {
  agent {
    kubernetes {
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: Always
            command:
            - sleep
            args:
            - "9999999"
            volumeMounts:
              - name: jenkins-docker-cfg
                mountPath: /kaniko/.docker
          volumes:
          - name: jenkins-docker-cfg
            projected:
              sources:
              - secret:
                  name: regcred
                  items:
                    - key: .dockerconfigjson
                      path: config.json
      """
    }
  }

  environment {
    IMAGE_TAG = ""
    REGISTRY_BASE = "docker.io/kenechukwujosiah"
    AUTH_REPO = "docker.io/kenechukwujosiah/eks-auth-demo"
    ADMIN_REPO = "docker.io/kenechukwujosiah/eks-admin-demo"
    USER_REPO = "docker.io/kenechukwujosiah/eks-user-demo"
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
          withCredentials([
            string(credentialsId: 'auth-port', variable: 'AUTH_PORT'),
            string(credentialsId: 'mongodb-host', variable: 'MONGODB_HOST'),
            string(credentialsId: 'mongodb-port', variable: 'MONGODB_PORT'),
            string(credentialsId: 'mongodb-username', variable: 'MONGODB_USERNAME'),
            string(credentialsId: 'mongodb-password', variable: 'MONGODB_PASSWORD'),
            string(credentialsId: 'mongodb-database', variable: 'MONGODB_DATABASE'),
            string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
          ]) {
            sh """
              /kaniko/executor \
                --context=${WORKSPACE} \
                --dockerfile=${WORKSPACE}/apps/auth/Dockerfile \
                --destination=${AUTH_REPO}:${IMAGE_TAG} \
                --destination=${AUTH_REPO}:latest \
                --build-arg=AUTH_PORT=$AUTH_PORT \
                --build-arg=MONGODB_HOST=$MONGODB_HOST \
                --build-arg=MONGODB_PORT=$MONGODB_PORT \
                --build-arg=MONGODB_USERNAME=$MONGODB_USERNAME \
                --build-arg=MONGODB_PASSWORD=$MONGODB_PASSWORD \
                --build-arg=MONGODB_DATABASE=$MONGODB_DATABASE \
                --build-arg=JWT_SECRET=$JWT_SECRET \
                --verbosity=info
            """
          }
        }
      }
    }

        stage('Admin') {
          steps {
            container('kaniko') {
              withCredentials([
                string(credentialsId: 'admin-port', variable: 'ADMIN_PORT'),
                string(credentialsId: 'mongodb-host', variable: 'MONGODB_HOST'),
                string(credentialsId: 'mongodb-port', variable: 'MONGODB_PORT'),
                string(credentialsId: 'mongodb-username', variable: 'MONGODB_USERNAME'),
                string(credentialsId: 'mongodb-password', variable: 'MONGODB_PASSWORD'),
                string(credentialsId: 'mongodb-database', variable: 'MONGODB_DATABASE'),
                string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
              ]) {
                sh """
                  /kaniko/executor \
                    --context=${WORKSPACE} \
                    --dockerfile=${WORKSPACE}/apps/admin/Dockerfile \
                    --destination=${ADMIN_REPO}:${IMAGE_TAG} \
                    --destination=${ADMIN_REPO}:latest \
                    --build-arg=ADMIN_PORT=$ADMIN_PORT \
                    --build-arg=MONGODB_HOST=$MONGODB_HOST \
                    --build-arg=MONGODB_PORT=$MONGODB_PORT \
                    --build-arg=MONGODB_USERNAME=$MONGODB_USERNAME \
                    --build-arg=MONGODB_PASSWORD=$MONGODB_PASSWORD \
                    --build-arg=MONGODB_DATABASE=$MONGODB_DATABASE \
                    --build-arg=JWT_SECRET=$JWT_SECRET \
                    --verbosity=info
                """
              }
            }
          }
        }

        stage('User') {
          steps {
            container('kaniko') {
              container('kaniko') {
              withCredentials([
                string(credentialsId: 'admin-port', variable: 'USER_PORT'),
                string(credentialsId: 'mongodb-host', variable: 'MONGODB_HOST'),
                string(credentialsId: 'mongodb-port', variable: 'MONGODB_PORT'),
                string(credentialsId: 'mongodb-username', variable: 'MONGODB_USERNAME'),
                string(credentialsId: 'mongodb-password', variable: 'MONGODB_PASSWORD'),
                string(credentialsId: 'mongodb-database', variable: 'MONGODB_DATABASE'),
                string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
              ]) {
                sh """
                  /kaniko/executor \
                    --context=${WORKSPACE} \
                    --dockerfile=${WORKSPACE}/apps/admin/Dockerfile \
                    --destination=${USER_REPO}:${IMAGE_TAG} \
                    --destination=${USER_REPO}:latest \
                    --build-arg=USER_PORT=$USER_PORT \
                    --build-arg=MONGODB_HOST=$MONGODB_HOST \
                    --build-arg=MONGODB_PORT=$MONGODB_PORT \
                    --build-arg=MONGODB_USERNAME=$MONGODB_USERNAME \
                    --build-arg=MONGODB_PASSWORD=$MONGODB_PASSWORD \
                    --build-arg=MONGODB_DATABASE=$MONGODB_DATABASE \
                    --build-arg=JWT_SECRET=$JWT_SECRET \
                    --verbosity=info
                """
              }
            }
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
