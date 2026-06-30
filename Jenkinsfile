pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'alexisvo'
        IMAGE_NAME      = 'ipark-app'
        IMAGE_TAG       = 'latest'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Spring Boot App') {
                    steps {
                        echo 'Giving execution permissions to Maven wrapper...'
                        sh 'chmod +x mvnw'

                        echo 'Building Java application using Maven...'
                        sh './mvnw clean package -DskipTests'
                    }
                }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Authenticating and pushing image to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully! New image is now live on Docker Hub.'
        }
        failure {
            echo 'Pipeline failed. Check the logs above for troubleshooting.'
        }
    }
}