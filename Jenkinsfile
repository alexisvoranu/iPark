pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        AWS_SSH_KEY           = credentials('aws-ssh-key')
        APP_NAME              = 'ipark-app'
        DOCKER_IMAGE          = 'alexisvo/ipark-app:latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker push $DOCKER_IMAGE'
            }
        }

        stage('Deploy to AWS via Ansible') {
            steps {
                sh 'mkdir -p ~/.ssh'
                sh 'cp $AWS_SSH_KEY ~/.ssh/cheie.pem'
                sh 'chmod 600 ~/.ssh/cheie.pem'

                dir('ansible') {
                    sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml deploy-ipark.yml'
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
            sh 'rm -f ~/.ssh/cheie.pem'
        }
    }
}