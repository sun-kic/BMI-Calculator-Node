pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "sunkic/bmi-calculator"
        ANSIBLE_NODE_IP = "3.64.126.28"
        ANSIBLE_PROJECT_PATH_ON_NODE = "/home/ubuntu/ansible_project"
        GIT_REPO_URL = "https://github.com/sun-kic/BMI-Calculator-Node.git"
    }
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from ${env.GIT_REPO_URL}"
                git branch: 'main',
                    credentialsId: 'github-pat',
                    url: "${env.GIT_REPO_URL}"
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    docker.build("${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", "--pull .")
                }
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    echo "Pushing Docker image ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Deploy via Ansible') {
            steps {
                echo "Deploying via Ansible to ${env.ANSIBLE_NODE_IP}"
                sshagent(credentials: ['ansible-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${env.ANSIBLE_NODE_IP} \\
                        "ansible-playbook ${env.ANSIBLE_PROJECT_PATH_ON_NODE}/playbooks/docker_setup.yml -i ${env.ANSIBLE_PROJECT_PATH_ON_NODE}/inventory.ini"
                    """
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${env.ANSIBLE_NODE_IP} \\
                        "ansible-playbook ${env.ANSIBLE_PROJECT_PATH_ON_NODE}/playbooks/app_deploy.yml -i ${env.ANSIBLE_PROJECT_PATH_ON_NODE}/inventory.ini -e docker_image_name=${env.DOCKER_IMAGE_NAME} -e docker_image_tag=${env.BUILD_NUMBER}"
                    """
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline finished. Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
