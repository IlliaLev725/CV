pipeline {
    agent any
    triggers {
        githubPush()
    }
    stages {
        stage('Clone repository') {
            steps {
                script {
                    git branch: 'main',
                    credentialsId: 'git-ssh',
                    url: 'https://github.com/IlliaLev725/Step_proj2.git'
                }
            }
        }
        stage('Start test') {
            steps {
                script {
                    sh """
                    docker build -t node-app .
                    docker run -p 3000:80 --rm node-app test
                    """
                }
            }
        }
        stage('Build image') {
            steps {
                script {
                    dockerImage = docker.build('illialev/test_repo:latest')
                }
            }
        }

        stage('Push image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'Docker-acc', url: '') {
                        dockerImage.push()
                    }
                }
            }
        }
    } 

    post {
        success {
            echo "Test successful"
        }
        failure {
            echo "Test failed"
        }
    }
}

