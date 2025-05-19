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
                image: docker:latest
                command: ['cat']
                tty: true
                securityContext:
                  privileged: true
                volumeMounts:
                - name: docker-graph-storage
                  mountPath: /var/lib/docker
              - name: docker-cli
                image: docker:24.0.5-cli
                command:
                - cat
                tty: true
                volumeMounts:
                - name: docker-socket
                  mountPath: /var/run
              - name: git
                image: alpine/git:latest
                command:
                - cat
                tty: true
              volumes:
              - name: docker-socket
                emptyDir: {}
              - name: docker-graph-storage
                emptyDir: {}
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

          container('docker-cli') {
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


      stage('Build Images') {
        parallel {
          stage('Build Auth Service') {
            steps {
              container('docker-cli') {
                sh 'docker compose build auth'
              }
            }
          }
          stage('Build User Service') {
            steps {
              container('docker-cli') {
                sh 'docker compose build user'
              }
            }
          }

          stage('Build Admin Service') {
            steps {
              container('docker-cli') {
                sh 'docker compose build admin'
              }
            }
          }
        }
      }

      stage('TAG Images'){
        parallel{
          stage('Tag Auth'){
            steps{
              container('docker-cli') {
                sh "docker tag auth ${AUTH_REPO}:${IMAGE_TAG}"
              }
            }
          }

          stage('Tag Admin'){
            steps{
              container('docker-cli') {
                sh "docker tag auth ${ADMIN_REPO}:${IMAGE_TAG}"
              }
            }
          }

          stage('Tag User'){
            steps{
              container('docker-cli') {
                sh "docker tag auth ${USER_REPO}:${IMAGE_TAG}"
              }
            }
          }
        }
        
      }

      stage ('Authenticate Docker') {
        steps{
          container('docker-cli') {
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
              container('docker-cli') {
                sh 'docker push ${AUTH_REPO}:${IMAGE_TAG}'
              }
            }
          }

          stage("Push Admin") {
            steps{
              container('docker-cli') {
                sh 'docker push ${ADMIN_REPO}:${IMAGE_TAG}'
              }
            }
          }

          stage("Push User") {
            steps{
              container('docker-cli') {
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