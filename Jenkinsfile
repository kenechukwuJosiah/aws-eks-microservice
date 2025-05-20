pipeline{
    agent{
        kubernetes {
          defaultContainer 'docker'
          yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: docker
                image: docker:24.0.5-cli
                command:
                - cat
                tty: true
                securityContext:
                  privileged: true
                volumeMounts:
                - name: docker-sock
                  mountPath: /var/run/docker.sock
              - name: git
                image: alpine/git:latest
                command:
                - cat
                tty: true
              volumes:
              - name: docker-socket
                emptyDir: {}
              - name: docker-sock
                hostPath:
                  path: /var/run/docker.sock
          '''
        }
    }

    stages{
      stage('Checkout') {
        steps {
          checkout scm
        }
      }

      stage('Prepare Utils') {
        steps {
          container('git') {
            sh 'git config --global --add safe.directory /home/jenkins/agent/workspace/eks_demo'
            script {
              env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
            }
          }

          container('docker') {
            withCredentials([string(credentialsId: 'reposity-base', variable: 'REGISTRY_BASE')]) {
              script {
                env.ADMIN_REPO = "${REGISTRY_BASE}/eks-admin-demo"
                env.USER_REPO = "${REGISTRY_BASE}/eks-user-demo"
                env.AUTH_REPO = "${REGISTRY_BASE}/eks-auth-demo"
              }
            }
          }

        }
      }

      stage('Load .env from Jenkins Credentials') {
      steps {
        withCredentials([file(credentialsId: 'env-file', variable: 'ENV_FILE')]) {
          sh '''
            echo "Loading env file"
            cp $ENV_FILE .env
            cat .env
          '''
        }
      }
    }


      stage('Build Images') {
        parallel {
          stage('Build Auth Service') {
            steps {
              container('docker') {
                sh 'docker compose --env-file .env build auth'
              }
            }
          }

          stage('Build User Service') {
            steps {
              container('docker') {
                sh 'docker compose --env-file .env build user'
              }
            }
          }

          stage('Build Admin Service') {
            steps {
              container('docker') {
                sh 'docker compose --env-file .env build admin'
              }
            }
          }
        }
      }

      stage('TAG Images'){
        parallel{
          stage('Tag Auth'){
            steps{
              container('docker') {
                sh "docker tag auth ${AUTH_REPO}:${IMAGE_TAG}"
              }
            }
          }

          stage('Tag Admin'){
            steps{
              container('docker') {
                sh "docker tag auth ${ADMIN_REPO}:${IMAGE_TAG}"
              }
            }
          }

          stage('Tag User'){
            steps{
              container('docker') {
                sh "docker tag auth ${USER_REPO}:${IMAGE_TAG}"
              }
            }
          }
        }
        
      }

      stage ('Authenticate Docker') {
        steps{
          container('docker') {
            withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          }
          }
        }
      }


      stage('Push Images to Repo') {
        parallel{
          stage("Push Auth") {
            steps{
              container('docker') {
                sh 'docker push ${AUTH_REPO}:${IMAGE_TAG}'
              }
            }
          }

          stage("Push Admin") {
            steps{
              container('docker') {
                sh 'docker push ${ADMIN_REPO}:${IMAGE_TAG}'
              }
            }
          }

          stage("Push User") {
            steps{
              container('docker') {
                sh 'docker push ${USER_REPO}:${IMAGE_TAG}'
              }
            }
          }
        }
      }
    }
    post{
        success{
            echo "Pipeline Executed Successfully..."
        }
        failure{
            echo "Pipeline Execution Failed..."
        }
    }
}